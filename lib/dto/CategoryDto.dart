import 'package:e_commerces/models/CategoryModel.dart';

class CategoryDto {
  const CategoryDto({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });

  final String categoryId;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      categoryId: json['category_id'].toString(),
      categoryName: json['category_name'].toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory CategoryDto.fromModel(CategoryModel model) {
    return CategoryDto(
      categoryId: model.categoryId,
      categoryName: model.categoryName,
      description: model.description,
      imageUrl: model.imageUrl,
      isActive: model.isActive,
    );
  }

  CategoryModel toModel() {
    return CategoryModel(
      categoryId: categoryId,
      categoryName: categoryName,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}

