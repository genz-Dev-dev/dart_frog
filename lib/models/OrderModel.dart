import 'package:mongo_dart/mongo_dart.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class ShippingInfoModel {
  final String recipientName;
  final String phone;
  final String street;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final String? trackingNumber;
  final String? courier;

  ShippingInfoModel({
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.city,
    this.state,
    required this.country,
    this.postalCode,
    this.trackingNumber,
    this.courier,
  });

  factory ShippingInfoModel.fromMap(Map<String, dynamic> map) {
    return ShippingInfoModel(
      recipientName: map['recipient_name'] as String,
      phone: map['phone'] as String,
      street: map['street'] as String,
      city: map['city'] as String,
      state: map['state'] as String?,
      country: map['country'] as String,
      postalCode: map['postal_code'] as String?,
      trackingNumber: map['tracking_number'] as String?,
      courier: map['courier'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipient_name': recipientName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'tracking_number': trackingNumber,
      'courier': courier,
    };
  }
}

class OrderModel {
  final ObjectId? id;
  final String orderId;
  final String customerId;
  final DateTime orderDate;
  final double totalAmount;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final String? couponCode;
  final OrderStatus status;
  final ShippingInfoModel? shippingInfo;
  final String? notes;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    this.id,
    required this.orderId,
    required this.customerId,
    DateTime? orderDate,
    required this.totalAmount,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    this.couponCode,
    this.status = OrderStatus.pending,
    this.shippingInfo,
    this.notes,
    this.deliveredAt,
    this.cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : orderDate = orderDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['_id'] as ObjectId?,
      orderId: map['order_id'] as String,
      customerId: map['customer_id'] as String,
      orderDate: map['order_date'] != null
          ? DateTime.parse(map['order_date'].toString())
          : DateTime.now(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      shippingFee: (map['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['coupon_code'] as String?,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      shippingInfo: map['shipping_info'] != null
          ? ShippingInfoModel.fromMap(
              map['shipping_info'] as Map<String, dynamic>)
          : null,
      notes: map['notes'] as String?,
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at'].toString())
          : null,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'].toString())
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
      'order_id': orderId,
      'customer_id': customerId,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'tax': tax,
      'discount': discount,
      'coupon_code': couponCode,
      'status': status.name,
      'shipping_info': shippingInfo?.toMap(),
      'notes': notes,
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    ObjectId? id,
    String? orderId,
    String? customerId,
    DateTime? orderDate,
    double? totalAmount,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? discount,
    String? couponCode,
    OrderStatus? status,
    ShippingInfoModel? shippingInfo,
    String? notes,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      couponCode: couponCode ?? this.couponCode,
      status: status ?? this.status,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      notes: notes ?? this.notes,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

