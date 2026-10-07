import 'package:mongo_dart/mongo_dart.dart';

class OrderDetailModel {
  final ObjectId? id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double discountPercent;
  final double subtotal;
  final DateTime createdAt;

  OrderDetailModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0.0,
    DateTime? createdAt,
  })  : subtotal = quantity * unitPrice * (1 - discountPercent / 100),
        createdAt = createdAt ?? DateTime.now();

  factory OrderDetailModel.fromMap(Map<String, dynamic> map) {
    return OrderDetailModel(
      id: map['_id'] as ObjectId?,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      productImage: map['product_image'] as String?,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percent': discountPercent,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

