import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/controllers/CategoryController.dart';

final _controller = CategoryController.build();

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _controller.getAll(context);
    case HttpMethod.post:
      return _controller.create(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}