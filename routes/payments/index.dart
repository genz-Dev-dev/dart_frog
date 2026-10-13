import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/controllers/PaymentController.dart';

/// POST /payments  — create ABA PayWay checkout session
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return context.read<PaymentController>().create(context);
}