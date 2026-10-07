import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/controllers/AuthController.dart';

final _controller = AuthController.create();

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return _controller.login(context);
}