import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../errors/PaymentException.dart';
import '../services/PaymentService.dart';
import '../utils/ApiResponse.dart';

class PaymentController {
  PaymentController(this._service);
  final PaymentService _service;

  // ---------------------------------------------------------------------------
  // POST /payments  — create checkout session
  // ---------------------------------------------------------------------------
  Future<Response> create(RequestContext context) {
    return _guard(() async {
      final body = await context.request.json() as Map<String, dynamic>;

      final orderId = body['order_id'] as String?;
      final customerId = body['customer_id'] as String?;
      if (orderId == null || customerId == null) {
        throw PaymentException('order_id and customer_id are required');
      }

      final result = await _service.createPayment(
        orderId: orderId,
        customerId: customerId,
        currency: body['currency'] as String? ?? 'USD',
        firstname: body['firstname'] as String? ?? '',
        lastname: body['lastname'] as String? ?? '',
        email: body['email'] as String? ?? '',
        phone: body['phone'] as String? ?? '',
      );

      return ApiResponse.created(
        data: result,
        message: 'Payment session created. Scan the QR to pay.',
      );
    });
  }

  // ---------------------------------------------------------------------------
  // POST /payments/callback  — ABA PayWay server-to-server notification
  // ---------------------------------------------------------------------------
  Future<Response> callback(RequestContext context) {
    return _guard(() async {
      // PayWay sends form-encoded body for callbacks
      final contentType =
          context.request.headers['content-type'] ?? '';
      Map<String, dynamic> body;

      if (contentType.contains('application/x-www-form-urlencoded')) {
        final raw = await context.request.body();
        body = Uri.splitQueryString(raw)
            .map((k, v) => MapEntry(k, v as dynamic));
      } else {
        body = await context.request.json() as Map<String, dynamic>;
      }

      final tranId = body['tran_id']?.toString();
      if (tranId == null) throw PaymentException('tran_id is required');

      await _service.syncStatus(tranId);
      // PayWay expects a 200 with {"status":"success"} to stop retries
      return Response.json(body: {'status': 'success'});
    });
  }

  // ---------------------------------------------------------------------------
  // GET /payments/:paymentId  — poll payment status
  // ---------------------------------------------------------------------------
  Future<Response> status(RequestContext context, String paymentId) {
    return _guard(() async {
      final p = await _service.syncStatus(paymentId);
      return ApiResponse.single(
        data: {
          'payment_id': p.paymentId,
          'order_id': p.orderId,
          'status': p.status.name,
          'amount': p.amount,
          'currency': p.currency,
          'paid_at': p.paidAt?.toIso8601String(),
          'transaction_id': p.transactionId,
        },
        message: 'Payment status retrieved.',
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Error guard — maps PaymentException → correct HTTP status
  // ---------------------------------------------------------------------------
  Future<Response> _guard(Future<Response> Function() run) async {
    try {
      return await run();
    } on PaymentException catch (e) {
      return ApiResponse.error(
        e.message,
        statusCode: e.statusCode,
        details: e.details != null ? {'gateway': e.details} : null,
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      return ApiResponse.serverError(ApiResponse.cleanError(e));
    }
  }
}