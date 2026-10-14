import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/models/ProductModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ProductRepository {
  static const String _collection = 'products';

  DbCollection get _col =>
      MongoDatabase.instance.collection(_collection);

  Future<List<ProductModel>> findAll() async {
    final docs = await _col.find().toList();
    return docs.map(ProductModel.fromMap).toList();
  }

  Future<void> save(ProductModel product) async {
    await _col.insertOne(product.toMap());
  }

  Future<ProductModel?> findById(String id) async {
    final doc = await _col.findOne(where.eq('product_id', id));
    if (doc == null) return null;
    return ProductModel.fromMap(doc);
  }

  /// Generic field update — uses raw \$set to avoid setAll issue.
  Future<void> update(String id, Map<String, dynamic> fields) async {
    fields['updated_at'] = DateTime.now().toIso8601String();
    await _col.updateOne(
      where.eq('product_id', id),
      {r'$set': fields},
    );
  }

  /// Set or clear the sale price for a product.
  Future<bool> setSalePrice(
    String productId, {
    required double? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
  }) async {
    final result = await _col.updateOne(
      where.eq('product_id', productId),
      {
        r'$set': {
          'sale_price': salePrice,
          'sale_start': saleStart?.toIso8601String(),
          'sale_end': saleEnd?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      },
    );
    return result.isSuccess;
  }

  /// Find all products that have a sale_price set.
  /// Active-sale filtering (date bounds) is done in Dart to avoid
  /// complex query chaining issues with this mongo_dart version.
  Future<List<ProductModel>> findOnSale() async {
    final docs = await _col.find(
      where.ne('sale_price', null),
    ).toList();

    final products = docs.map(ProductModel.fromMap).toList();

    // Filter to only those whose sale window is currently active
    return products.where((p) => p.isOnSale).toList();
  }
}