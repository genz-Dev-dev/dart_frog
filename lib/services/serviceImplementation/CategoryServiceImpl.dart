import 'package:e_commerces/dto/CategoryDto.dart';
import 'package:e_commerces/repositories/CategoryRepository.dart';
import 'package:e_commerces/services/CategoryService.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CategoryServiceImpl implements CategoryService {
  CategoryServiceImpl(this._repo);
  final CategoryRepository _repo;

  @override
  Future<CategoryDto> create(CategoryDto category) async {
    final exists = await _repo.existsById(category.categoryId);
    if (exists) {
      throw Exception(
        'Category with id "${category.categoryId}" already exists.',
      );
    }
    final model = category.toModel().copyWith(id: ObjectId());
    final saved = await _repo.save(model);
    return CategoryDto.fromModel(saved);
  }

  @override
  Future<List<CategoryDto>> getAll() async {
    final models = await _repo.findAll();
    return models.map(CategoryDto.fromModel).toList();
  }

  @override
  Future<CategoryDto> getById(String categoryId) async {
    final model = await _repo.findById(categoryId);
    if (model == null) {
      throw Exception('Category "$categoryId" not found.');
    }
    return CategoryDto.fromModel(model);
  }

  @override
  Future<CategoryDto> update(
    String categoryId,
    Map<String, dynamic> fields,
  ) async {
    final exists = await _repo.findById(categoryId);
    if (exists == null) {
      throw Exception('Category "$categoryId" not found.');
    }
    final updated = await _repo.update(categoryId, fields);
    return CategoryDto.fromModel(updated!);
  }

  @override
  Future<void> delete(String categoryId) async {
    final exists = await _repo.findById(categoryId);
    if (exists == null) {
      throw Exception('Category "$categoryId" not found.');
    }
    await _repo.delete(categoryId);
  }
}
