import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/controllers/ProductController.dart';

final _controller = ProductController.create();

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return _controller.uploadImage(context, id);
    case HttpMethod.delete:
      return _controller.removeImage(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

