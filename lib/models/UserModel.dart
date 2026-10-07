import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId? objectId;
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  User({
    this.objectId,
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Public-safe JSON (no password hash)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Full MongoDB document
  Map<String, dynamic> toMap() {
    return {
      if (objectId != null) '_id': objectId,
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      objectId: map['_id'] as ObjectId?,
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }
}