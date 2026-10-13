import 'package:mongo_dart/mongo_dart.dart';
import '../models/OrderModel.dart';
import '../database/Mongodb.dart';

abstract class OrderRepository {
  Future<double?> getTotal(String orderId); // null if order doesn't exist
  Future<void> markPaid(String orderId);
}

/// MongoDB implementation of [OrderRepository].
class MongoOrderRepository implements OrderRepository {
  MongoOrderRepository(this._db);
  final Db _db;

  DbCollection get _col => _db.collection('orders');

  @override
  Future<double?> getTotal(String orderId) async {
    final doc = await _col.findOne(where.eq('order_id', orderId));
    if (doc == null) return null;
    return (doc['total_amount'] as num?)?.toDouble();
  }

  @override
  Future<void> markPaid(String orderId) async {
    await _col.updateOne(
      where.eq('order_id', orderId),
      {
        '\$set': {
          'status': OrderStatus.confirmed.name,
          'updated_at': DateTime.now().toIso8601String(),
        }
      },
    );
  }
}