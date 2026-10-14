import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/controllers/ProductController.dart';

final _controller = ProductController.create();

/// GET  /products/[id]  — get single product
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return _controller.getProductById(context, id);
}
