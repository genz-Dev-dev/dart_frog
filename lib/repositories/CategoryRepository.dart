import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/models/CategoryModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CategoryRepository {
  static const String _collection = 'categories';

  DbCollection get _col => MongoDatabase.instance.collection(_collection);

  // CREATE
  Future<CategoryModel> save(CategoryModel category) async {
    await _col.insertOne(category.toMap());
    return category;
  }

  // READ ALL
  Future<List<CategoryModel>> findAll() async {
    final docs = await _col.find().toList();
    return docs.map(CategoryModel.fromMap).toList();
  }

  // READ ONE
  Future<CategoryModel?> findById(String categoryId) async {
    final doc = await _col.findOne(where.eq('category_id', categoryId));
    return doc == null ? null : CategoryModel.fromMap(doc);
  }

  // UPDATE
  Future<CategoryModel?> update(
    String categoryId,
    Map<String, dynamic> fields,
  ) async {
    fields['updated_at'] = DateTime.now().toIso8601String();
    await _col.updateOne(
      where.eq('category_id', categoryId),
      {r'$set': fields},
    );
    return findById(categoryId);
  }

  // DELETE
  Future<bool> delete(String categoryId) async {
    final result = await _col.deleteOne(where.eq('category_id', categoryId));
    return result.isSuccess;
  }

  // CHECK DUPLICATE
  Future<bool> existsById(String categoryId) async {
    final doc = await _col.findOne(where.eq('category_id', categoryId));
    return doc != null;
  }
}
