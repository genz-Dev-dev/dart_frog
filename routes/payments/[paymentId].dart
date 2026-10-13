import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/controllers/PaymentController.dart';

/// GET /payments/:paymentId  — poll payment status
Future<Response> onRequest(RequestContext context, String paymentId) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return context.read<PaymentController>().status(context, paymentId);
}