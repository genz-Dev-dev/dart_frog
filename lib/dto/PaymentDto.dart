import 'package:e_commerces/models/PaymentModel.dart';

class CreatePaymentDto {
  const CreatePaymentDto({
    required this.orderId,
    required this.customerId,
    this.currency = 'USD',
    this.firstname = '',
    this.lastname = '',
    this.email = '',
    this.phone = '',
  });

  final String orderId;
  final String customerId;
  final String currency;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;

  factory CreatePaymentDto.fromJson(Map<String, dynamic> json) {
    return CreatePaymentDto(
      orderId: json['order_id'].toString(),
      customerId: json['customer_id'].toString(),
      currency: (json['currency']?.toString() ?? 'USD').toUpperCase(),
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class PaymentDto {
  const PaymentDto({
    required this.paymentId,
    required this.orderId,
    required this.customerId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.paidAt,
  });

  final String paymentId;
  final String orderId;
  final String customerId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final DateTime? paidAt;

  factory PaymentDto.fromModel(PaymentModel model) {
    return PaymentDto(
      paymentId: model.paymentId,
      orderId: model.orderId,
      customerId: model.customerId,
      amount: model.amount,
      currency: model.currency ?? 'USD',
      paymentMethod: model.paymentMethod.name,
      status: model.status.name,
      transactionId: model.transactionId,
      paidAt: model.paidAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'customer_id': customerId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}
