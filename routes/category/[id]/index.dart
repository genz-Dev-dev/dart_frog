import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/controllers/CategoryController.dart';

final _controller = CategoryController.build();

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

