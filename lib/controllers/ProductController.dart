import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/dto/ProductDto.dart';
import 'package:e_commerces/repositories/ProductRepository.dart';
import 'package:e_commerces/services/ProductService.dart';
import 'package:e_commerces/services/serviceImplementation/ProductServiceImpl.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

class ProductController {
  ProductController(this._productService);
  final ProductService _productService;

  static ProductController create() {
    final repo = ProductRepository();
    final service = ProductServiceImpl(repo);
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
        data: products.map((p) => p.toJson()).toList(),
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
      final dto = ProductDto.fromJson(body);
      final saved = await _productService.addProduct(dto);

      return ApiResponse.created(
        data: saved.toJson(),
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
        data: product.toJson(),
        message: 'Product retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // PATCH /products/:id/sale
  // Body: { "sale_price": 29.99, "sale_start": "2026-10-14", "sale_end": "2026-10-31" }
  // Remove sale: { "sale_price": null }
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
        data: updated!.toJson(),
        message:
            salePrice != null ? 'Sale price set successfully.' : 'Sale price removed.',
      );
    } on FormatException {
      return ApiResponse.badRequest(
        'Invalid JSON or date format. Use ISO 8601 (e.g. 2026-10-31).',
      );
    } catch (e) {
      return ApiResponse.badRequest(ApiResponse.cleanError(e));
    }
  }

  // ---------------------------------------------------------------------------
  // POST /products/:id/image or /products/images — upload images to Cloudinary
  // ---------------------------------------------------------------------------
  Future<Response> uploadImage(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();

      final filesList = <({Uint8List bytes, String contentType, String filename})>[];
      String? cloudName;
      var targetProductId = id.trim();

      final header = context.request.headers['content-type'] ?? '';

      if (header.contains('multipart/form-data')) {
        final formData = await context.request.formData();

        if (formData.fields['product_id'] != null &&
            formData.fields['product_id']!.isNotEmpty) {
          targetProductId = formData.fields['product_id']!.trim();
        }
        if (formData.fields['cloud_name'] != null &&
            formData.fields['cloud_name']!.isNotEmpty) {
          cloudName = formData.fields['cloud_name']!.trim();
        }

        for (final entry in formData.files.entries) {
          final file = entry.value;
          final bytes = Uint8List.fromList(await file.readAsBytes());
          if (bytes.isNotEmpty) {
            filesList.add((
              bytes: bytes,
              contentType: file.contentType.mimeType,
              filename: file.name,
            ));
          }
        }
      } else {
        final body = await context.request.json() as Map<String, dynamic>;

        if (body['product_id'] != null) {
          targetProductId = body['product_id'].toString().trim();
        }
        if (body['cloud_name'] != null) {
          cloudName = body['cloud_name'].toString().trim();
        }

        if (body['images'] is List) {
          final list = body['images'] as List;
          for (var i = 0; i < list.length; i++) {
            final item = list[i];
            if (item is String && item.isNotEmpty) {
              var base64Data = item;
              var cType = 'image/jpeg';
              if (item.contains(',')) {
                final prefix = item.substring(0, item.indexOf(','));
                base64Data = item.substring(item.indexOf(',') + 1);
                if (prefix.contains(':') && prefix.contains(';')) {
                  cType = prefix.split(':')[1].split(';')[0];
                }
              }
              final bytes = base64Decode(base64Data);
              if (bytes.isNotEmpty) {
                filesList.add((
                  bytes: bytes,
                  contentType: cType,
                  filename: 'product_${targetProductId}_$i.jpg',
                ));
              }
            }
          }
        } else {
          final raw = body['image'] ?? body['image_base64'] ?? body['file'];
          if (raw is String && raw.isNotEmpty) {
            var base64Data = raw;
            var cType = body['content_type'] as String? ?? 'image/jpeg';
            if (raw.contains(',')) {
              final prefix = raw.substring(0, raw.indexOf(','));
              base64Data = raw.substring(raw.indexOf(',') + 1);
              if (prefix.contains(':') && prefix.contains(';')) {
                cType = prefix.split(':')[1].split(';')[0];
              }
            }
            final bytes = base64Decode(base64Data);
            if (bytes.isNotEmpty) {
              filesList.add((
                bytes: bytes,
                contentType: cType,
                filename:
                    body['filename'] as String? ?? 'product_$targetProductId.jpg',
              ));
            }
          }
        }
      }

      if (targetProductId.isEmpty) {
        return ApiResponse.badRequest(
          'product_id is required in URL or form-data/JSON body.',
        );
      }

      if (filesList.isEmpty) {
        return ApiResponse.badRequest(
          'No image files found. Send via form-data (file fields) or JSON { "images": ["<base64>", ...] } or { "image": "<base64>" }.',
        );
      }

      final uploadedUrls = await _productService.uploadProductImages(
        targetProductId,
        files: filesList,
        cloudName: cloudName,
      );

      final updated = await _productService.getProductById(targetProductId);

      return ApiResponse.single(
        data: {
          'product_id': targetProductId,
          'count': uploadedUrls.length,
          'uploaded_urls': uploadedUrls,
          if (updated != null) 'product': updated.toJson(),
        },
        message:
            '${uploadedUrls.length} image(s) uploaded and attached to product successfully.',
      );
    } on FormatException {
      return ApiResponse.badRequest(
        'Invalid request format (expected multipart/form-data or JSON).',
      );
    } catch (e) {
      final msg = ApiResponse.cleanError(e);
      return msg.contains('not found')
          ? ApiResponse.notFound(msg)
          : ApiResponse.badRequest(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE /products/:id/image — remove image URL from product
  // ---------------------------------------------------------------------------
  Future<Response> removeImage(RequestContext context, String id) async {
    try {
      await MongoDatabase.connect();
      final body = await context.request.json() as Map<String, dynamic>;
      final imageUrl = body['image_url'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        return ApiResponse.badRequest('"image_url" is required in JSON body.');
      }

      await _productService.removeProductImage(id, imageUrl);
      final updated = await _productService.getProductById(id);

      return ApiResponse.single(
        data: {
          'removed_url': imageUrl,
          if (updated != null) 'product': updated.toJson(),
        },
        message: 'Product image removed successfully.',
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
  // GET /products/sale — list products currently on sale
  // ---------------------------------------------------------------------------
  Future<Response> getProductsOnSale(RequestContext context) async {
    try {
      await MongoDatabase.connect();
      final products = await _productService.getProductsOnSale();

      return ApiResponse.multiple(
        data: products.map((p) => p.toJson()).toList(),
        message: 'On-sale products retrieved successfully.',
      );
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }
}
