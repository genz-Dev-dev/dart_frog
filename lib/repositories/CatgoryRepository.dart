import 'package:mongo_dart/mongo_dart.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/models/CategoryModel.dart';

class CategoryRepository {
  static const String _collection = 'categories';

  DbCollection get _col => MongoDatabase.instance.collection(_collection);

  Future<CategoryModel> save(CategoryModel category) async {
    await _col.insertOne(category.toMap());
    return category;
  }
}