import 'dart:convert';
import 'package:e_commerces/errors/PaymentException.dart';
import 'package:e_commerces/models/PaymentModel.dart';
import 'package:e_commerces/payway/PayWayClient.dart';
import 'package:e_commerces/repositories/OrderRepository.dart';
import 'package:e_commerces/repositories/PaymentRepository.dart';

class PaymentService {
  PaymentService({
    required PayWayClient payway,
    required PaymentRepository payments,
    required OrderRepository orders,
    required this.callbackUrl,
  })  : _payway = payway,
        _payments = payments,
        _orders = orders;

  final PayWayClient _payway;
  final PaymentRepository _payments;
  final OrderRepository _orders;
  final String callbackUrl;

  // ---------------------------------------------------------------------------
  // Create a PayWay KHQR checkout session
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createPayment({
    required String orderId,
    required String customerId,
    String currency = 'USD',
    String firstname = '',
    String lastname = '',
    String email = '',
    String phone = '',
  }) async {
    if (currency != 'USD' && currency != 'KHR') {
      throw PaymentException('Currency must be USD or KHR');
    }

    // Amount comes from YOUR database — never trust the client.
    final amount = await _orders.getTotal(orderId);
    if (amount == null) {
      throw PaymentException('Order not found', statusCode: 404);
    }

    final payment = PaymentModel(
      paymentId: 'PAY${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      customerId: customerId,
      amount: amount,
      currency: currency,
      paymentMethod: PaymentMethod.mobilePay,
    );
    await _payments.insert(payment);

    final result = await _payway.createKhqrPayment(
      tranId: payment.paymentId,
      amount: amount,
      currency: currency,
      callbackUrl: callbackUrl,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phone: phone,
      items: [
        {'name': 'Order $orderId', 'quantity': 1, 'price': amount},
      ],
    );

    final code = (result['status'] as Map?)?['code']?.toString();
    final ok = code == '00' || code == '0';

    await _payments.save(payment.copyWith(
      status: ok ? PaymentStatus.processing : PaymentStatus.failed,
      gatewayResponse: jsonEncode(result),
    ));

    if (!ok) {
      throw PaymentException(
        'PayWay rejected the request',
        statusCode: 502,
        details: result['status'],
      );
    }

    return {
      'payment_id': payment.paymentId,
      'amount': amount,
      'currency': currency,
      'qr_string': result['qr_string'],
      'abapay_deeplink': result['abapay_deeplink'],
      'checkout_qr_url': result['checkout_qr_url'],
    };
  }

  // ---------------------------------------------------------------------------
  // Sync payment status with PayWay — used by callback + status polling
  // ---------------------------------------------------------------------------
  Future<PaymentModel> syncStatus(String paymentId) async {
    final payment = await _payments.findByPaymentId(paymentId);
    if (payment == null) {
      throw PaymentException('Payment not found', statusCode: 404);
    }

    final res = await _payway.checkTransaction(paymentId);
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) return payment; // code 6: PayWay doesn't have it yet

    final status = _mapStatus(data);
    final refunded = (data['refund_amount'] as num?)?.toDouble() ?? 0;
    final wasCompleted = payment.status == PaymentStatus.completed;

    final updated = payment.copyWith(
      status: status,
      transactionId: data['apv']?.toString(),
      gatewayResponse: jsonEncode(res),
      refundedAmount: refunded > 0 ? refunded : null,
      paidAt: status == PaymentStatus.completed && payment.paidAt == null
          ? DateTime.now()
          : null,
      refundedAt: (status == PaymentStatus.refunded ||
                  status == PaymentStatus.partialRefund) &&
              payment.refundedAt == null
          ? DateTime.now()
          : null,
    );
    await _payments.save(updated);

    // Fulfil the order only once.
    if (status == PaymentStatus.completed && !wasCompleted) {
      await _orders.markPaid(payment.orderId);
    }
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Map PayWay payment_status strings to our enum
  // ---------------------------------------------------------------------------
  PaymentStatus _mapStatus(Map<String, dynamic> d) {
    switch (d['payment_status']) {
      case 'APPROVED':
        return PaymentStatus.completed;
      case 'PRE-AUTH':
        return PaymentStatus.processing;
      case 'DECLINED':
        return PaymentStatus.failed;
      case 'CANCELLED':
        return PaymentStatus.cancelled;
      case 'REFUNDED':
        final refunded = (d['refund_amount'] as num?)?.toDouble() ?? 0;
        final paid = (d['payment_amount'] as num?)?.toDouble() ?? 0;
        return refunded >= paid && paid > 0
            ? PaymentStatus.refunded
            : PaymentStatus.partialRefund;
      case 'PENDING':
      default:
        return PaymentStatus.pending;
    }
  }
}