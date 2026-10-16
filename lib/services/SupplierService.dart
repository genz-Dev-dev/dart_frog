import 'package:e_commerces/dto/SupplierDto.dart';

abstract class SupplierService {
  Future<SupplierDto> create(SupplierDto supplier);
  Future<List<SupplierDto>> getAll();
  Future<SupplierDto> getById(String supplierId);
  Future<SupplierDto> update(String supplierId, Map<String, dynamic> fields);
  Future<void> delete(String supplierId);
}
