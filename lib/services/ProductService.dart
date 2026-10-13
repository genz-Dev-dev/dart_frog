import '../models/ProductModel.dart';
import '../repositories/ProductRepository.dart';

class ProductService {
  final ProductRepository _productRepository;

  ProductService(this._productRepository);

  Future<List<ProductModel>> getAllProducts() async {
    return _productRepository.findAll();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    await _productRepository.save(product);
    return product;
  }

  Future<ProductModel?> getProductById(String id) async {
    return _productRepository.findById(id);
  }

  /// Set a sale price on a product.
  /// Pass [salePrice] = null to remove the sale.
  /// [saleStart] and [saleEnd] are optional date bounds.
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
          'Sale price (\$${salePrice.toStringAsFixed(2)}) must be lower than the regular price (\$${product.price.toStringAsFixed(2)}).');
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

  /// Remove the sale price from a product.
  Future<void> clearSalePrice(String productId) async {
    await setSalePrice(productId, salePrice: null);
  }

  /// Get all products currently on sale.
  Future<List<ProductModel>> getProductsOnSale() async {
    return _productRepository.findOnSale();
  }
}