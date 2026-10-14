import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/controllers/ProductController.dart';

final _controller = ProductController.create();

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _controller.getAllProducts(context);
    case HttpMethod.post:
      return _controller.addProduct(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}