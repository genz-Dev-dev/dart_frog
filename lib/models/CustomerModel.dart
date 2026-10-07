import 'package:mongo_dart/mongo_dart.dart';

enum Gender { male, female, other, preferNotToSay }

class AddressModel {
  final String label; // home, work, other
  final String street;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final bool isDefault;

  AddressModel({
    required this.label,
    required this.street,
    required this.city,
    this.state,
    required this.country,
    this.postalCode,
    this.isDefault = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      label: map['label'] as String,
      street: map['street'] as String,
      city: map['city'] as String,
      state: map['state'] as String?,
      country: map['country'] as String,
      postalCode: map['postal_code'] as String?,
      isDefault: map['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }
}

class CustomerModel {
  final ObjectId? id;
  final String customerId;
  final String name;
  final Gender gender;
  final String city;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final List<AddressModel> addresses;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    this.id,
    required this.customerId,
    required this.name,
    required this.gender,
    required this.city,
    this.email,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    List<AddressModel>? addresses,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : addresses = addresses ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['_id'] as ObjectId?,
      customerId: map['customer_id'] as String,
      name: map['name'] as String,
      gender: Gender.values.firstWhere(
        (g) => g.name == map['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
      city: map['city'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'].toString())
          : null,
      addresses: (map['addresses'] as List<dynamic>?)
              ?.map((a) => AddressModel.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
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
      'customer_id': customerId,
      'name': name,
      'gender': gender.name,
      'city': city,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    ObjectId? id,
    String? customerId,
    String? name,
    Gender? gender,
    String? city,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    List<AddressModel>? addresses,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      addresses: addresses ?? this.addresses,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

