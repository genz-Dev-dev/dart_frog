import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import '../controllers/PaymentController.dart';
import '../payway/PayWayClient.dart';
import '../repositories/OrderRepository.dart';
import '../repositories/PaymentRepository.dart';
import '../services/PaymentService.dart';

/// Singleton dependency container.
/// Reads credentials from environment variables.
///
/// Required env vars:
///   MONGO_URI              — e.g. mongodb://localhost:27017/ecommerce
///   PAYWAY_MERCHANT_ID     — e.g. ec478715
///   PAYWAY_API_KEY         — e.g. 1c6251cdbe1952...
///   PAYWAY_CALLBACK_URL    — public URL PayWay will POST to, e.g. https://yourdomain.com/payments/callback
///
/// Optional:
///   PAYWAY_BASE_URL        — defaults to sandbox
class Dependencies {
  Dependencies._(this.paymentController);
  final PaymentController paymentController;

  static Dependencies? _instance;

  static Future<Dependencies> instance() async {
    if (_instance != null) return _instance!;

    final env = Platform.environment;

    // ── MongoDB ──────────────────────────────────────────────────────────────
    final mongoUri = env['MONGO_URI'] ?? 'mongodb://localhost:27017/ecommerce';
    final db = await Db.create(mongoUri);
    await db.open();
    await db.collection('payments').createIndex(
      keys: {'payment_id': 1},
      unique: true,
    );

    // ── ABA PayWay ───────────────────────────────────────────────────────────
    final merchantId =
        env['PAYWAY_MERCHANT_ID'] ?? 'ec478715';         // sandbox default
    final apiKey = env['PAYWAY_API_KEY'] ??
        '1c6251cdbe1952e76438967aa1451f57009366d7';       // sandbox default
    final baseUrl = env['PAYWAY_BASE_URL'] ??
        'https://checkout-sandbox.payway.com.kh';

    final payway = PayWayClient(
      merchantId: merchantId,
      apiKey: apiKey,
      baseUrl: baseUrl,
    );

    // ── Services ─────────────────────────────────────────────────────────────
    final callbackUrl = env['PAYWAY_CALLBACK_URL'] ??
        'http://localhost:8080/payments/callback';        // dev fallback

    final service = PaymentService(
      payway: payway,
      payments: PaymentRepository(db),
      orders: MongoOrderRepository(db),
      callbackUrl: callbackUrl,
    );

    return _instance = Dependencies._(PaymentController(service));
  }
}