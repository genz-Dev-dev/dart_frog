import 'package:mongo_dart/mongo_dart.dart';

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  paypal,
  stripe,
  mobilePay,
  cryptocurrency,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partialRefund,
}

class PaymentModel {
  final ObjectId? id;
  final String paymentId;
  final String orderId;
  final String customerId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId;       // external gateway transaction ID
  final String? gatewayResponse;     // raw response from payment gateway
  final String? currency;
  final String? cardLastFour;        // last 4 digits if card payment
  final String? cardBrand;           // Visa, Mastercard, etc.
  final double? refundedAmount;
  final String? refundReason;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    this.id,
    required this.paymentId,
    required this.orderId,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.gatewayResponse,
    this.currency = 'USD',
    this.cardLastFour,
    this.cardBrand,
    this.refundedAmount,
    this.refundReason,
    this.paidAt,
    this.refundedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['_id'] as ObjectId?,
      paymentId: map['payment_id'] as String,
      orderId: map['order_id'] as String,
      customerId: map['customer_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (m) => m.name == map['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transaction_id'] as String?,
      gatewayResponse: map['gateway_response'] as String?,
      currency: map['currency'] as String? ?? 'USD',
      cardLastFour: map['card_last_four'] as String?,
      cardBrand: map['card_brand'] as String?,
      refundedAmount: map['refunded_amount'] != null
          ? (map['refunded_amount'] as num).toDouble()
          : null,
      refundReason: map['refund_reason'] as String?,
      paidAt: map['paid_at'] != null
          ? DateTime.parse(map['paid_at'].toString())
          : null,
      refundedAt: map['refunded_at'] != null
          ? DateTime.parse(map['refunded_at'].toString())
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'payment_id': paymentId,
      'order_id': orderId,
      'customer_id': customerId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'transaction_id': transactionId,
      'gateway_response': gatewayResponse,
      'currency': currency,
      'card_last_four': cardLastFour,
      'card_brand': cardBrand,
      'refunded_amount': refundedAmount,
      'refund_reason': refundReason,
      'paid_at': paidAt?.toIso8601String(),
      'refunded_at': refundedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    ObjectId? id,
    String? paymentId,
    String? orderId,
    String? customerId,
    double? amount,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? transactionId,
    String? gatewayResponse,
    String? currency,
    String? cardLastFour,
    String? cardBrand,
    double? refundedAmount,
    String? refundReason,
    DateTime? paidAt,
    DateTime? refundedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      currency: currency ?? this.currency,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      cardBrand: cardBrand ?? this.cardBrand,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundReason: refundReason ?? this.refundReason,
      paidAt: paidAt ?? this.paidAt,
      refundedAt: refundedAt ?? this.refundedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

