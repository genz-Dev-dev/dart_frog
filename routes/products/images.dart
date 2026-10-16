import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/controllers/ProductController.dart';

final _controller = ProductController.create();

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  // product_id is provided in form-data or JSON body
  return _controller.uploadImage(context, '');
}

