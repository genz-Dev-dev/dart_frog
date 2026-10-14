import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/controllers/ProductController.dart';

final _controller = ProductController.create();

/// GET /products/sale — list all products currently on sale
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return _controller.getProductsOnSale(context);
}
