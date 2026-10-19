import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/dto/CategoryDto.dart';
import 'package:e_commerces/repositories/CategoryRepository.dart';
import 'package:e_commerces/services/CategoryService.dart';
import 'package:e_commerces/services/serviceImplementation/CategoryServiceImpl.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

class CategoryController {
  CategoryController(this._service);
  final CategoryService _service;

  static CategoryController build() {
    final repo = CategoryRepository();
    final service = CategoryServiceImpl(repo);
    return CategoryController(service);
  }

  // ---------------------------------------------------------------------------
  // POST /category — create
  // ---------------------------------------------------------------------------
  Future<Response> create(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;

      final categoryId = body['category_id']?.toString().trim();
      final categoryName = body['category_name']?.toString().trim();

      if (categoryId == null || categoryId.isEmpty) {
        return ApiResponse.badRequest('category_id is required.');
      }
      if (categoryName == null || categoryName.isEmpty) {
        return ApiResponse.badRequest('category_name is required.');
      }

      final dto = CategoryDto.fromJson(body);
      final saved = await _service.create(dto);

      return ApiResponse.created(
        data: saved.toJson(),
        message: 'Category created successfully.',
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      return ApiResponse.badRequest(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // GET /category — list all
  // ---------------------------------------------------------------------------
  Future<Response> getAll(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final categories = await _service.getAll();
      return ApiResponse.multiple(
        data: categories.map((c) => c.toJson()).toList(),
        message: 'Categories retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // GET /category/:id — get one
  // ---------------------------------------------------------------------------
  Future<Response> getById(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final category = await _service.getById(id);
      return ApiResponse.single(
        data: category.toJson(),
        message: 'Category retrieved successfully.',
      );
    } catch (e) {
      final msg = ApiResponse.cleanError(e);
      return msg.contains('not found')
          ? ApiResponse.notFound(msg)
          : ApiResponse.serverError(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // PUT /category/:id — update
  // ---------------------------------------------------------------------------
  Future<Response> update(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;

      final allowed = <String, dynamic>{};
      if (body.containsKey('category_name')) {
        allowed['category_name'] = body['category_name'];
      }
      if (body.containsKey('description')) {
        allowed['description'] = body['description'];
      }
      if (body.containsKey('image_url')) {
        allowed['image_url'] = body['image_url'];
      }
      if (body.containsKey('is_active')) {
        allowed['is_active'] = body['is_active'];
      }

      if (allowed.isEmpty) {
        return ApiResponse.badRequest(
          'Provide at least one field to update: category_name, description, image_url, is_active.',
        );
      }

      final updated = await _service.update(id, allowed);
      return ApiResponse.single(
        data: updated.toJson(),
        message: 'Category updated successfully.',
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      final msg = ApiResponse.cleanError(e);
      return msg.contains('not found')
          ? ApiResponse.notFound(msg)
          : ApiResponse.serverError(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE /category/:id — delete
  // ---------------------------------------------------------------------------
  Future<Response> delete(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      await _service.delete(id);
      return ApiResponse.message('Category "$id" deleted successfully.');
    } catch (e) {
      final msg = ApiResponse.cleanError(e);
      return msg.contains('not found')
          ? ApiResponse.notFound(msg)
          : ApiResponse.serverError(msg);
    }
  }
}
