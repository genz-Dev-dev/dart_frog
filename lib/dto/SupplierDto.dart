import 'package:e_commerces/models/SupplierModel.dart';

class SupplierDto {
  const SupplierDto({
    required this.supplierId,
    required this.supplierName,
    required this.city,
    required this.phone,
    this.email,
    this.address,
    this.country,
    this.isActive = true,
  });

  final String supplierId;
  final String supplierName;
  final String city;
  final String phone;
  final String? email;
  final String? address;
  final String? country;
  final bool isActive;

  factory SupplierDto.fromJson(Map<String, dynamic> json) {
    return SupplierDto(
      supplierId: json['supplier_id'].toString(),
      supplierName: json['supplier_name'].toString(),
      city: json['city'].toString(),
      phone: json['phone'].toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      country: json['country']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory SupplierDto.fromModel(SupplierModel model) {
    return SupplierDto(
      supplierId: model.supplierId,
      supplierName: model.supplierName,
      city: model.city,
      phone: model.phone,
      email: model.email,
      address: model.address,
      country: model.country,
      isActive: model.isActive,
    );
  }

  SupplierModel toModel() {
    return SupplierModel(
      supplierId: supplierId,
      supplierName: supplierName,
      city: city,
      phone: phone,
      email: email,
      address: address,
      country: country,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'city': city,
      'phone': phone,
      'email': email,
      'address': address,
      'country': country,
      'is_active': isActive,
    };
  }
}
