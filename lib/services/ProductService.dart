import 'dart:typed_data';

import 'package:e_commerces/dto/ProductDto.dart';

abstract class ProductService {
  Future<List<ProductDto>> getAllProducts();
  Future<ProductDto> addProduct(ProductDto product);
  Future<ProductDto?> getProductById(String id);
  Future<void> setSalePrice(
    String productId, {
    required double? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
  });
  Future<void> clearSalePrice(String productId);
  Future<List<ProductDto>> getProductsOnSale();
  Future<String> uploadProductImage(
    String productId, {
    required Uint8List bytes,
    required String contentType,
    String? filename,
    String? cloudName,
  });
  Future<List<String>> uploadProductImages(
    String productId, {
    required List<({Uint8List bytes, String contentType, String filename})> files,
    String? cloudName,
  });
  Future<void> removeProductImage(String productId, String imageUrl);
}