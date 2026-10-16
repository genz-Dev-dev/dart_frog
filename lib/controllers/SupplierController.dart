import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/dto/SupplierDto.dart';
import 'package:e_commerces/repositories/SupplierRepository.dart';
import 'package:e_commerces/services/SupplierService.dart';
import 'package:e_commerces/services/serviceImplementation/SupplierServiceImpl.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

class SupplierController {
  SupplierController(this._service);
  final SupplierService _service;

  static SupplierController build() {
    final repo = SupplierRepository();
    final service = SupplierServiceImpl(repo);
    return SupplierController(service);
  }

  // POST /suppliers
  Future<Response> create(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;

      final supplierId = body['supplier_id']?.toString().trim();
      final supplierName = body['supplier_name']?.toString().trim();

      if (supplierId == null || supplierId.isEmpty) {
        return ApiResponse.badRequest('supplier_id is required.');
      }
      if (supplierName == null || supplierName.isEmpty) {
        return ApiResponse.badRequest('supplier_name is required.');
      }

      final dto = SupplierDto.fromJson(body);
      final saved = await _service.create(dto);

      return ApiResponse.created(
        data: saved.toJson(),
        message: 'Supplier created successfully.',
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      return ApiResponse.badRequest(ApiResponse.cleanError(e));
    }
  }

  // GET /suppliers
  Future<Response> getAll(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final suppliers = await _service.getAll();
      return ApiResponse.multiple(
        data: suppliers.map((s) => s.toJson()).toList(),
        message: 'Suppliers retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }

  // GET /suppliers/:id
  Future<Response> getById(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final supplier = await _service.getById(id);
      return ApiResponse.single(
        data: supplier.toJson(),
        message: 'Supplier retrieved successfully.',
      );
    } catch (e) {
      final msg = ApiResponse.cleanError(e);
      return msg.contains('not found')
          ? ApiResponse.notFound(msg)
          : ApiResponse.serverError(msg);
    }
  }

  // PUT /suppliers/:id
  Future<Response> update(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;

      final allowed = <String, dynamic>{};
      if (body.containsKey('supplier_name')) allowed['supplier_name'] = body['supplier_name'];
      if (body.containsKey('city')) allowed['city'] = body['city'];
      if (body.containsKey('phone')) allowed['phone'] = body['phone'];
      if (body.containsKey('email')) allowed['email'] = body['email'];
      if (body.containsKey('address')) allowed['address'] = body['address'];
      if (body.containsKey('country')) allowed['country'] = body['country'];
      if (body.containsKey('is_active')) allowed['is_active'] = body['is_active'];

      if (allowed.isEmpty) {
        return ApiResponse.badRequest('Provide at least one field to update.');
      }

      final updated = await _service.update(id, allowed);
      return ApiResponse.single(
        data: updated.toJson(),
        message: 'Supplier updated successfully.',
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

  // DELETE /suppliers/:id
  Future<Response> delete(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      await _service.delete(id);
      return ApiResponse.message('Supplier "$id" deleted successfully.');
    } catch (e) {
      final msg = ApiResponse.cleanError(e);
      return msg.contains('not found')
          ? ApiResponse.notFound(msg)
          : ApiResponse.serverError(msg);
    }
  }
}

