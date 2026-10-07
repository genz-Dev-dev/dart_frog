import 'package:mongo_dart/mongo_dart.dart';

class CartItemModel {
  final String productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final double? discountPercent;

  CartItemModel({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.unitPrice,
    required this.quantity,
    this.discountPercent,
  });

  double get subtotal {
    final effectivePrice = discountPercent != null
        ? unitPrice * (1 - discountPercent! / 100)
        : unitPrice;
    return effectivePrice * quantity;
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      productImage: map['product_image'] as String?,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      discountPercent: map['discount_percent'] != null
          ? (map['discount_percent'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'unit_price': unitPrice,
      'quantity': quantity,
      'discount_percent': discountPercent,
      'subtotal': subtotal,
    };
  }
}

class CartModel {
  final ObjectId? id;
  final String cartId;
  final String customerId;
  final List<CartItemModel> items;
  final String? couponCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    this.id,
    required this.cartId,
    required this.customerId,
    List<CartItemModel>? items,
    this.couponCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : items = items ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['_id'] as ObjectId?,
      cartId: map['cart_id'] as String,
      customerId: map['customer_id'] as String,
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => CartItemModel.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      couponCode: map['coupon_code'] as String?,
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
      'cart_id': cartId,
      'customer_id': customerId,
      'items': items.map((i) => i.toMap()).toList(),
      'coupon_code': couponCode,
      'total_amount': totalAmount,
      'total_items': totalItems,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

