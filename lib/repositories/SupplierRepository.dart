import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/models/SupplierModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

class SupplierRepository {
  static const String _collection = 'suppliers';

  DbCollection get _col => MongoDatabase.instance.collection(_collection);

  Future<bool> existsById(String supplierId) async {
    final count = await _col.count(where.eq('supplier_id', supplierId));
    return count > 0;
  }

  Future<SupplierModel> save(SupplierModel supplier) async {
    await _col.insertOne(supplier.toMap());
    return supplier;
  }

  Future<List<SupplierModel>> findAll() async {
    final docs = await _col.find().toList();
    return docs.map(SupplierModel.fromMap).toList();
  }

  Future<SupplierModel?> findById(String supplierId) async {
    final doc = await _col.findOne(where.eq('supplier_id', supplierId));
    if (doc == null) return null;
    return SupplierModel.fromMap(doc);
  }

  Future<SupplierModel?> update(
    String supplierId,
    Map<String, dynamic> fields,
  ) async {
    fields['updated_at'] = DateTime.now().toIso8601String();
    await _col.updateOne(
      where.eq('supplier_id', supplierId),
      {r'$set': fields},
    );
    return findById(supplierId);
  }

  Future<bool> delete(String supplierId) async {
    final res = await _col.deleteOne(where.eq('supplier_id', supplierId));
    return res.isSuccess;
  }
}

