import 'package:mongo_dart/mongo_dart.dart';

class SupplierModel {
  final ObjectId? id;
  final String supplierId;
  final String supplierName;
  final String city;
  final String phone;
  final String? email;
  final String? address;
  final String? country;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierModel({
    this.id,
    required this.supplierId,
    required this.supplierName,
    required this.city,
    required this.phone,
    this.email,
    this.address,
    this.country,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['_id'] as ObjectId?,
      supplierId: map['supplier_id'] as String,
      supplierName: map['supplier_name'] as String,
      city: map['city'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      country: map['country'] as String?,
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
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'city': city,
      'phone': phone,
      'email': email,
      'address': address,
      'country': country,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    ObjectId? id,
    String? supplierId,
    String? supplierName,
    String? city,
    String? phone,
    String? email,
    String? address,
    String? country,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

