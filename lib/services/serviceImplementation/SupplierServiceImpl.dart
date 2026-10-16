import 'package:e_commerces/dto/SupplierDto.dart';
import 'package:e_commerces/repositories/SupplierRepository.dart';
import 'package:e_commerces/services/SupplierService.dart';
import 'package:mongo_dart/mongo_dart.dart';

class SupplierServiceImpl implements SupplierService {
  SupplierServiceImpl(this._repo);
  final SupplierRepository _repo;

  @override
  Future<SupplierDto> create(SupplierDto supplier) async {
    final exists = await _repo.existsById(supplier.supplierId);
    if (exists) {
      throw Exception('Supplier with id "${supplier.supplierId}" already exists.');
    }
    final model = supplier.toModel().copyWith(id: ObjectId());
    final saved = await _repo.save(model);
    return SupplierDto.fromModel(saved);
  }

  @override
  Future<List<SupplierDto>> getAll() async {
    final models = await _repo.findAll();
    return models.map(SupplierDto.fromModel).toList();
  }

  @override
  Future<SupplierDto> getById(String supplierId) async {
    final model = await _repo.findById(supplierId);
    if (model == null) {
      throw Exception('Supplier "$supplierId" not found.');
    }
    return SupplierDto.fromModel(model);
  }

  @override
  Future<SupplierDto> update(String supplierId, Map<String, dynamic> fields) async {
    final exists = await _repo.findById(supplierId);
    if (exists == null) {
      throw Exception('Supplier "$supplierId" not found.');
    }
    final updated = await _repo.update(supplierId, fields);
    return SupplierDto.fromModel(updated!);
  }

  @override
  Future<void> delete(String supplierId) async {
    final exists = await _repo.findById(supplierId);
    if (exists == null) {
      throw Exception('Supplier "$supplierId" not found.');
    }
    await _repo.delete(supplierId);
  }
}
