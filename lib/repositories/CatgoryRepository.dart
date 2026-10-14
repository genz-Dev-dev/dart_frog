import 'package:mongo_dart/mongo_dart.dart';
import '../database/Mongodb.dart';
import '../models/CategoryModel.dart';

class CategoryRepository {
  static const String _collection = 'categories';

  DbCollection get _col => MongoDatabase.instance.collection(_collection);

  Future<CategoryModel> save(CategoryModel category) async {
    await _col.insertOne(category.toMap());
    return category;
  }
}