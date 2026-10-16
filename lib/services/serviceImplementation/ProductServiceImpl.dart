import 'dart:typed_data';

import 'package:e_commerces/dto/ProductDto.dart';
import 'package:e_commerces/repositories/ProductRepository.dart';
import 'package:e_commerces/services/CloudinaryStorageService.dart';
import 'package:e_commerces/services/ImageStorage.dart';
import 'package:e_commerces/services/ProductService.dart';

class ProductServiceImpl implements ProductService {
  ProductServiceImpl(this._productRepository, [ImageStorage? imageStorage])
      : _imageStorage = imageStorage ?? CloudinaryStorageService();

  final ProductRepository _productRepository;
  final ImageStorage _imageStorage;

  @override
  Future<List<ProductDto>> getAllProducts() async {
    final products = await _productRepository.findAll();
    return products.map(ProductDto.fromModel).toList();
  }

  @override
  Future<ProductDto> addProduct(ProductDto product) async {
    final model = product.toModel();
    await _productRepository.save(model);
    return ProductDto.fromModel(model);
  }

  @override
  Future<ProductDto?> getProductById(String id) async {
    final model = await _productRepository.findById(id);
    if (model == null) return null;
    return ProductDto.fromModel(model);
  }

  @override
  Future<String> uploadProductImage(
    String productId, {
    required Uint8List bytes,
    required String contentType,
    String? filename,
    String? cloudName,
  }) async {
    final product = await _productRepository.findById(productId);
    if (product == null) {
      throw Exception('Product with id "$productId" not found.');
    }

    final storage = cloudName != null && cloudName.isNotEmpty
        ? CloudinaryStorageService(cloudName: cloudName)
        : _imageStorage;

    final key =
        'product_detail/${productId}_${DateTime.now().millisecondsSinceEpoch}';

    final imageUrl = await storage.upload(
      key: key,
      bytes: bytes,
      contentType: contentType,
      filename: filename,
    );

    await _productRepository.addImage(productId, imageUrl);
    return imageUrl;
  }

  @override
  Future<List<String>> uploadProductImages(
    String productId, {
    required List<({Uint8List bytes, String contentType, String filename})> files,
    String? cloudName,
  }) async {
    final product = await _productRepository.findById(productId);
    if (product == null) {
      throw Exception('Product with id "$productId" not found.');
    }

    final storage = cloudName != null && cloudName.isNotEmpty
        ? CloudinaryStorageService(cloudName: cloudName)
        : _imageStorage;

    final uploadedUrls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final key =
          'product_detail/${productId}_${DateTime.now().millisecondsSinceEpoch}_$i';

      final imageUrl = await storage.upload(
        key: key,
        bytes: file.bytes,
        contentType: file.contentType,
        filename: file.filename,
      );
      uploadedUrls.add(imageUrl);
    }

    await _productRepository.addImages(productId, uploadedUrls);
    return uploadedUrls;
  }

  @override
  Future<void> removeProductImage(String productId, String imageUrl) async {
    final product = await _productRepository.findById(productId);
    if (product == null) {
      throw Exception('Product with id "$productId" not found.');
    }
    await _productRepository.removeImage(productId, imageUrl);
  }

  @override
  Future<void> setSalePrice(
    String productId, {
    required double? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
  }) async {
    if (salePrice != null && salePrice <= 0) {
      throw Exception('Sale price must be greater than 0.');
    }

    final product = await _productRepository.findById(productId);
    if (product == null) {
      throw Exception('Product not found.');
    }

    if (salePrice != null && salePrice >= product.price) {
      throw Exception(
        'Sale price (\$${salePrice.toStringAsFixed(2)}) must be lower than the regular price (\$${product.price.toStringAsFixed(2)}).',
      );
    }

    if (saleStart != null &&
        saleEnd != null &&
        saleEnd.isBefore(saleStart)) {
      throw Exception('Sale end date must be after sale start date.');
    }

    final success = await _productRepository.setSalePrice(
      productId,
      salePrice: salePrice,
      saleStart: saleStart,
      saleEnd: saleEnd,
    );

    if (!success) {
      throw Exception('Failed to update sale price.');
    }
  }

  @override
  Future<void> clearSalePrice(String productId) async {
    await setSalePrice(productId, salePrice: null);
  }

  @override
  Future<List<ProductDto>> getProductsOnSale() async {
    final products = await _productRepository.findOnSale();
    return products.map(ProductDto.fromModel).toList();
  }
}

