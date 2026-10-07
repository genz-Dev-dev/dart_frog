import 'package:mongo_dart/mongo_dart.dart';

enum NotificationType {
  orderConfirmed,
  orderShipped,
  orderDelivered,
  orderCancelled,
  paymentSuccess,
  paymentFailed,
  refundProcessed,
  newPromotion,
  productRestock,
  reviewReply,
}

class NotificationModel {
  final ObjectId? id;
  final String notificationId;
  final String customerId;
  final NotificationType type;
  final String title;
  final String message;
  final String? referenceId;   // order_id, payment_id, product_id etc.
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    required this.notificationId,
    required this.customerId,
    required this.type,
    required this.title,
    required this.message,
    this.referenceId,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['_id'] as ObjectId?,
      notificationId: map['notification_id'] as String,
      customerId: map['customer_id'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.orderConfirmed,
      ),
      title: map['title'] as String,
      message: map['message'] as String,
      referenceId: map['reference_id'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'notification_id': notificationId,
      'customer_id': customerId,
      'type': type.name,
      'title': title,
      'message': message,
      'reference_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

