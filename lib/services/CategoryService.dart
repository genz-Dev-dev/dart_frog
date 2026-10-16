import 'package:e_commerces/dto/CategoryDto.dart';

abstract class CategoryService {
  Future<CategoryDto> create(CategoryDto category);
  Future<List<CategoryDto>> getAll();
  Future<CategoryDto> getById(String categoryId);
  Future<CategoryDto> update(String categoryId, Map<String, dynamic> fields);
  Future<void> delete(String categoryId);
}
