import 'package:mongo_dart/mongo_dart.dart';

class ProductModel {
  ProductModel({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.supplierId,
    required this.price,
    required this.stock,
    this.id,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
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
  }) : images = images ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['_id'] as ObjectId?,
      productId: map['product_id'].toString(),
      productName: map['product_name'].toString(),
      categoryId: map['category_id'].toString(),
      supplierId: map['supplier_id'].toString(),
      price: (map['price'] as num).toDouble(),
      salePrice: map['sale_price'] != null
          ? (map['sale_price'] as num).toDouble()
          : null,
      saleStart: map['sale_start'] != null
          ? DateTime.parse(map['sale_start'].toString())
          : null,
      saleEnd: map['sale_end'] != null
          ? DateTime.parse(map['sale_end'].toString())
          : null,
      stock: (map['stock'] as num).toInt(),
      description: map['description'] != null
          ? map['description'].toString()
          : null,
      images: (map['images'] as List<dynamic>? ?? const <dynamic>[])
          .map((image) => image.toString())
          .toList(),
      discountPercent: map['discount_percent'] != null
          ? (map['discount_percent'] as num).toDouble()
          : null,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      sku: map['sku'] != null ? map['sku'].toString() : null,
      barcode: map['barcode'] != null ? map['barcode'].toString() : null,
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
  final ObjectId? id;
  final String productId;
  final String productName;
  final String categoryId;
  final String supplierId;
  final double price; // original / regular price
  final double? salePrice; // sale price (null = not on sale)
  final DateTime? saleStart; // when the sale begins
  final DateTime? saleEnd; // when the sale ends
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

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  /// Returns true when there is an active sale price right now.
  bool get isOnSale {
    if (salePrice == null) return false;
    final now = DateTime.now();
    if (saleStart != null && now.isBefore(saleStart!)) return false;
    if (saleEnd != null && now.isAfter(saleEnd!)) return false;
    return true;
  }

  /// The effective price the customer pays: salePrice (if active) → discounted
  /// price → regular price.
  double get effectivePrice {
    if (isOnSale) return salePrice!;
    if (discountPercent != null && discountPercent! > 0) {
      return price - (price * discountPercent! / 100);
    }
    return price;
  }

  /// How much the customer saves (in currency).
  double get savingsAmount => price - effectivePrice;

  /// Saving as a percentage of the original price.
  double get savingsPercent => price > 0 ? (savingsAmount / price * 100) : 0.0;

  bool get inStock => stock > 0;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'product_id': productId,
      'product_name': productName,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'price': price,
      'sale_price': salePrice,
      'sale_start': saleStart?.toIso8601String(),
      'sale_end': saleEnd?.toIso8601String(),
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
      'is_on_sale': isOnSale,
      'effective_price': effectivePrice,
      'savings_amount': savingsAmount,
      'savings_percent': double.parse(savingsPercent.toStringAsFixed(2)),
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
    double? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
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
      salePrice: salePrice ?? this.salePrice,
      saleStart: saleStart ?? this.saleStart,
      saleEnd: saleEnd ?? this.saleEnd,
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
