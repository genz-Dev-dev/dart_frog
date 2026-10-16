import 'package:e_commerces/models/PaymentModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PaymentRepository {
  PaymentRepository(this._db);
  final Db _db;

  DbCollection get _col => _db.collection('payments');

  Future<void> insert(PaymentModel p) => _col.insertOne(p.toMap());

  Future<PaymentModel?> findByPaymentId(String paymentId) async {
    final doc = await _col.findOne(where.eq('payment_id', paymentId));
    return doc == null ? null : PaymentModel.fromMap(doc);
  }

  Future<void> save(PaymentModel p) =>
      _col.replaceOne(where.eq('payment_id', p.paymentId), p.toMap());

  Future<List<PaymentModel>> findByOrderId(String orderId) async {
    final docs = await _col.find(where.eq('order_id', orderId)).toList();
    return docs.map(PaymentModel.fromMap).toList();
  }

  Future<List<PaymentModel>> findByCustomerId(String customerId) async {
    final docs = await _col.find(where.eq('customer_id', customerId)).toList();
    return docs.map(PaymentModel.fromMap).toList();
  }
}
