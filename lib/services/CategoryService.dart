import 'package:mongo_dart/mongo_dart.dart';
import '../repositories/CategoryRepository.dart';
import '../models/CategoryModel.dart';

class CategoryService {
  final CategoryRepository _repo;

  CategoryService(this._repo);

  // CREATE
  Future<CategoryModel> create(CategoryModel category) async {
    final exists = await _repo.existsById(category.categoryId);
    if (exists) {
      throw Exception(
          'Category with id "${category.categoryId}" already exists.');
    }
    return _repo.save(category.copyWith(id: ObjectId()));
  }

  // READ ALL
  Future<List<CategoryModel>> getAll() => _repo.findAll();

  // READ ONE
  Future<CategoryModel> getById(String categoryId) async {
    final category = await _repo.findById(categoryId);
    if (category == null) {
      throw Exception('Category "$categoryId" not found.');
    }
    return category;
  }

  // UPDATE
  Future<CategoryModel> update(
      String categoryId, Map<String, dynamic> fields) async {
    final exists = await _repo.findById(categoryId);
    if (exists == null) {
      throw Exception('Category "$categoryId" not found.');
    }
    final updated = await _repo.update(categoryId, fields);
    return updated!;
  }

  // DELETE
  Future<void> delete(String categoryId) async {
    final exists = await _repo.findById(categoryId);
    if (exists == null) {
      throw Exception('Category "$categoryId" not found.');
    }
    await _repo.delete(categoryId);
  }
}