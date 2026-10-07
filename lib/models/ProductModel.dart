import 'package:mongo_dart/mongo_dart.dart';

class ProductModel {
  final ObjectId? id;
  final String productId;
  final String productName;
  final String categoryId;
  final String supplierId;
  final double price;
  final int stock;
  final String? description;
  final List<String> images;
  final double? discountPercent;
  final double rating;
  final int reviewCount;
  final String? sku;
  final String? barcode;
  final double? weight;
  final Map<String, dynamic>? dimensions; // {width, height, depth}
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.supplierId,
    required this.price,
    required this.stock,
    this.description,
    List<String>? images,
    this.discountPercent,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.sku,
    this.barcode,
    this.weight,
    this.dimensions,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : images = images ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get finalPrice {
    if (discountPercent != null && discountPercent! > 0) {
      return price - (price * discountPercent! / 100);
    }
    return price;
  }

  bool get inStock => stock > 0;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['_id'] as ObjectId?,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      categoryId: map['category_id'] as String,
      supplierId: map['supplier_id'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      description: map['description'] as String?,
      images: List<String>.from(map['images'] ?? []),
      discountPercent: map['discount_percent'] != null
          ? (map['discount_percent'] as num).toDouble()
          : null,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] as int? ?? 0,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      dimensions: map['dimensions'] as Map<String, dynamic>?,
      isActive: map['is_active'] as bool? ?? true,
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
      'product_id': productId,
      'product_name': productName,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'price': price,
      'stock': stock,
      'description': description,
      'images': images,
      'discount_percent': discountPercent,
      'rating': rating,
      'review_count': reviewCount,
      'sku': sku,
      'barcode': barcode,
      'weight': weight,
      'dimensions': dimensions,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    ObjectId? id,
    String? productId,
    String? productName,
    String? categoryId,
    String? supplierId,
    double? price,
    int? stock,
    String? description,
    List<String>? images,
    double? discountPercent,
    double? rating,
    int? reviewCount,
    String? sku,
    String? barcode,
    double? weight,
    Map<String, dynamic>? dimensions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      images: images ?? this.images,
      discountPercent: discountPercent ?? this.discountPercent,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

