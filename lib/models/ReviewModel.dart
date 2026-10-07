import 'package:mongo_dart/mongo_dart.dart';

class ReviewModel {
  final ObjectId? id;
  final String reviewId;
  final String productId;
  final String customerId;
  final String orderId;
  final int rating;          // 1 - 5
  final String? comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    this.id,
    required this.reviewId,
    required this.productId,
    required this.customerId,
    required this.orderId,
    required this.rating,
    this.comment,
    List<String>? images,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.isVisible = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5'),
        images = images ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['_id'] as ObjectId?,
      reviewId: map['review_id'] as String,
      productId: map['product_id'] as String,
      customerId: map['customer_id'] as String,
      orderId: map['order_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      images: List<String>.from(map['images'] ?? []),
      isVerifiedPurchase: map['is_verified_purchase'] as bool? ?? false,
      helpfulCount: map['helpful_count'] as int? ?? 0,
      isVisible: map['is_visible'] as bool? ?? true,
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
      'review_id': reviewId,
      'product_id': productId,
      'customer_id': customerId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': helpfulCount,
      'is_visible': isVisible,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

