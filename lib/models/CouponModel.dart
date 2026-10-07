import 'package:mongo_dart/mongo_dart.dart';

enum DiscountType { percentage, fixedAmount }

class CouponModel {
  final ObjectId? id;
  final String couponId;
  final String code;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;  // cap for percentage discounts
  final int? usageLimit;
  final int usedCount;
  final String? applicableCategoryId;  // null = applies to all
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponModel({
    this.id,
    required this.couponId,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    this.usedCount = 0,
    this.applicableCategoryId,
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUsable =>
      isActive && !isExpired && (usageLimit == null || usedCount < usageLimit!);

  double computeDiscount(double orderTotal) {
    if (!isUsable) return 0;
    if (minOrderAmount != null && orderTotal < minOrderAmount!) return 0;

    if (discountType == DiscountType.fixedAmount) {
      return discountValue.clamp(0, orderTotal);
    } else {
      final discount = orderTotal * discountValue / 100;
      return maxDiscountAmount != null
          ? discount.clamp(0, maxDiscountAmount!)
          : discount;
    }
  }

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      id: map['_id'] as ObjectId?,
      couponId: map['coupon_id'] as String,
      code: map['code'] as String,
      discountType: DiscountType.values.firstWhere(
        (t) => t.name == map['discount_type'],
        orElse: () => DiscountType.percentage,
      ),
      discountValue: (map['discount_value'] as num).toDouble(),
      minOrderAmount: map['min_order_amount'] != null
          ? (map['min_order_amount'] as num).toDouble()
          : null,
      maxDiscountAmount: map['max_discount_amount'] != null
          ? (map['max_discount_amount'] as num).toDouble()
          : null,
      usageLimit: map['usage_limit'] as int?,
      usedCount: map['used_count'] as int? ?? 0,
      applicableCategoryId: map['applicable_category_id'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      startDate: DateTime.parse(map['start_date'].toString()),
      endDate: DateTime.parse(map['end_date'].toString()),
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
      'coupon_id': couponId,
      'code': code,
      'discount_type': discountType.name,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'max_discount_amount': maxDiscountAmount,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'applicable_category_id': applicableCategoryId,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

