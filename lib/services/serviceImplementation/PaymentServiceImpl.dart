import 'dart:convert';

import 'package:e_commerces/dto/PaymentDto.dart';
import 'package:e_commerces/errors/PaymentException.dart';
import 'package:e_commerces/models/PaymentModel.dart';
import 'package:e_commerces/payway/PayWayClient.dart';
import 'package:e_commerces/repositories/OrderRepository.dart';
import 'package:e_commerces/repositories/PaymentRepository.dart';
import 'package:e_commerces/services/PaymentService.dart';

class PaymentServiceImpl implements PaymentService {
  PaymentServiceImpl({
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

  @override
  Future<Map<String, dynamic>> createPayment(CreatePaymentDto dto) async {
    if (dto.currency != 'USD' && dto.currency != 'KHR') {
      throw PaymentException('Currency must be USD or KHR');
    }

    final amount = await _orders.getTotal(dto.orderId);
    if (amount == null) {
      throw PaymentException('Order not found', statusCode: 404);
    }

    final payment = PaymentModel(
      paymentId: 'PAY${DateTime.now().millisecondsSinceEpoch}',
      orderId: dto.orderId,
      customerId: dto.customerId,
      amount: amount,
      currency: dto.currency,
      paymentMethod: PaymentMethod.mobilePay,
    );
    await _payments.insert(payment);

    final result = await _payway.createKhqrPayment(
      tranId: payment.paymentId,
      amount: amount,
      currency: dto.currency,
      callbackUrl: callbackUrl,
      firstname: dto.firstname,
      lastname: dto.lastname,
      email: dto.email,
      phone: dto.phone,
      items: [
        {'name': 'Order ${dto.orderId}', 'quantity': 1, 'price': amount},
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
      'currency': dto.currency,
      'qr_string': result['qr_string'],
      'abapay_deeplink': result['abapay_deeplink'],
      'checkout_qr_url': result['checkout_qr_url'],
    };
  }

  @override
  Future<PaymentModel> syncStatus(String paymentId) async {
    final payment = await _payments.findByPaymentId(paymentId);
    if (payment == null) {
      throw PaymentException('Payment not found', statusCode: 404);
    }

    final res = await _payway.checkTransaction(paymentId);
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) return payment;

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

    if (status == PaymentStatus.completed && !wasCompleted) {
      await _orders.markPaid(payment.orderId);
    }
    return updated;
  }

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

