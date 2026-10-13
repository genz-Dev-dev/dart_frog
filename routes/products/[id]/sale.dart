import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/controllers/ProductController.dart';

final _controller = ProductController.create();

/// PATCH /products/[id]/sale  — set or remove sale price
/// Body: { "sale_price": 29.99, "sale_start": "2026-10-14", "sale_end": "2026-10-31" }
/// Remove: { "sale_price": null }
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return _controller.setSalePrice(context, id);
}
