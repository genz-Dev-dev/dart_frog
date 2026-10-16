import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/controllers/SupplierController.dart';

final _controller = SupplierController.build();

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _controller.getById(context, id);
    case HttpMethod.put:
      return _controller.update(context, id);
    case HttpMethod.delete:
      return _controller.delete(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

