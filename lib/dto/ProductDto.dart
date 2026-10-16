import 'package:e_commerces/models/ProductModel.dart';

class ProductDto {
  const ProductDto({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.supplierId,
    required this.price,
    required this.stock,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    this.description,
    this.images = const [],
    this.discountPercent,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.sku,
    this.barcode,
    this.weight,
    this.dimensions,
    this.isActive = true,
    this.isOnSale = false,
    this.effectivePrice,
    this.savingsAmount,
    this.savingsPercent,
  });

  final String productId;
  final String productName;
  final String categoryId;
  final String supplierId;
  final double price;
  final int stock;
  final double? salePrice;
  final DateTime? saleStart;
  final DateTime? saleEnd;
  final String? description;
  final List<String> images;
  final double? discountPercent;
  final double rating;
  final int reviewCount;
  final String? sku;
  final String? barcode;
  final double? weight;
  final Map<String, dynamic>? dimensions;
  final bool isActive;
  final bool isOnSale;
  final double? effectivePrice;
  final double? savingsAmount;
  final double? savingsPercent;

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      productId: json['product_id'].toString(),
      productName: json['product_name'].toString(),
      categoryId: json['category_id'].toString(),
      supplierId: json['supplier_id'].toString(),
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      salePrice: json['sale_price'] != null
          ? (json['sale_price'] as num).toDouble()
          : null,
      saleStart: json['sale_start'] != null
          ? DateTime.parse(json['sale_start'].toString())
          : null,
      saleEnd: json['sale_end'] != null
          ? DateTime.parse(json['sale_end'].toString())
          : null,
      description: json['description']?.toString(),
      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      discountPercent: json['discount_percent'] != null
          ? (json['discount_percent'] as num).toDouble()
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      isOnSale: json['is_on_sale'] as bool? ?? false,
      effectivePrice: (json['effective_price'] as num?)?.toDouble(),
      savingsAmount: (json['savings_amount'] as num?)?.toDouble(),
      savingsPercent: (json['savings_percent'] as num?)?.toDouble(),
    );
  }

  factory ProductDto.fromModel(ProductModel model) {
    return ProductDto(
      productId: model.productId,
      productName: model.productName,
      categoryId: model.categoryId,
      supplierId: model.supplierId,
      price: model.price,
      stock: model.stock,
      salePrice: model.salePrice,
      saleStart: model.saleStart,
      saleEnd: model.saleEnd,
      description: model.description,
      images: model.images,
      discountPercent: model.discountPercent,
      rating: model.rating,
      reviewCount: model.reviewCount,
      sku: model.sku,
      barcode: model.barcode,
      weight: model.weight,
      dimensions: model.dimensions,
      isActive: model.isActive,
      isOnSale: model.isOnSale,
      effectivePrice: model.effectivePrice,
      savingsAmount: model.savingsAmount,
      savingsPercent: model.savingsPercent,
    );
  }

  ProductModel toModel() {
    return ProductModel(
      productId: productId,
      productName: productName,
      categoryId: categoryId,
      supplierId: supplierId,
      price: price,
      stock: stock,
      salePrice: salePrice,
      saleStart: saleStart,
      saleEnd: saleEnd,
      description: description,
      images: images,
      discountPercent: discountPercent,
      rating: rating,
      reviewCount: reviewCount,
      sku: sku,
      barcode: barcode,
      weight: weight,
      dimensions: dimensions,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'price': price,
      'stock': stock,
      'sale_price': salePrice,
      'sale_start': saleStart?.toIso8601String(),
      'sale_end': saleEnd?.toIso8601String(),
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
      'savings_percent': savingsPercent,
    };
  }
}

