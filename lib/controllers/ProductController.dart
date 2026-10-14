import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/models/ProductModel.dart';
import 'package:e_commerces/services/ProductService.dart';
import 'package:e_commerces/repositories/ProductRepository.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

class ProductController {

  ProductController(this._productService);
  final ProductService _productService;

  static ProductController create() {
    final repo = ProductRepository();
    final service = ProductService(repo);
    return ProductController(service);
  }

  // ---------------------------------------------------------------------------
  // GET /products
  // ---------------------------------------------------------------------------
  Future<Response> getAllProducts(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final products = await _productService.getAllProducts();

      return ApiResponse.multiple(
        data: products.map((p) => p.toMap()).toList(),
        message: 'Products retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // POST /products
  // ---------------------------------------------------------------------------
  Future<Response> addProduct(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;
      final product = ProductModel.fromMap(body);
      final saved = await _productService.addProduct(product);

      return ApiResponse.created(
        data: saved.toMap(),
        message: 'Product added successfully.',
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // GET /products/:id
  // ---------------------------------------------------------------------------
  Future<Response> getProductById(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final product = await _productService.getProductById(id);

      if (product == null) {
        return ApiResponse.notFound('Product with id "$id" not found.');
      }

      return ApiResponse.single(
        data: product.toMap(),
        message: 'Product retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // PATCH /products/:id/sale  — set or remove sale price
  // Body: { "sale_price": 29.99, "sale_start": "2026-10-14", "sale_end": "2026-10-31" }
  // Remove: { "sale_price": null }
  // ---------------------------------------------------------------------------
  Future<Response> setSalePrice(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;

      final salePriceRaw = body['sale_price'];
      final salePrice =
          salePriceRaw != null ? (salePriceRaw as num).toDouble() : null;

      final saleStart = body['sale_start'] != null
          ? DateTime.parse(body['sale_start'] as String)
          : null;
      final saleEnd = body['sale_end'] != null
          ? DateTime.parse(body['sale_end'] as String)
          : null;

      await _productService.setSalePrice(
        id,
        salePrice: salePrice,
        saleStart: saleStart,
        saleEnd: saleEnd,
      );

      final updated = await _productService.getProductById(id);

      return ApiResponse.single(
        data: updated!.toMap(),
        message: salePrice != null
            ? 'Sale price set successfully.'
            : 'Sale price removed.',
      );
    } on FormatException {
      return ApiResponse.badRequest(
          'Invalid JSON or date format. Use ISO 8601 (e.g. 2026-10-31).');
    } catch (e) {
      return ApiResponse.badRequest(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // GET /products/sale — list products currently on sale
  // ---------------------------------------------------------------------------
  Future<Response> getProductsOnSale(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final products = await _productService.getProductsOnSale();

      return ApiResponse.multiple(
        data: products.map((p) => p.toMap()).toList(),
        message: 'On-sale products retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }
}