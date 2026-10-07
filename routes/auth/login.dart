import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/repositories/UserRepository.dart';
import '../../lib/services/UserService.dart';
import '../../lib/database/Mongodb.dart';
final _userRepository = UserRepository();
final _authService = AuthService(_userRepository);

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    // Ensure MongoDB is connected before any DB operation
    await MongoDatabase.connect();

    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Email and password are required.'},
      );
    }

    final token = await _authService.login(
      email: email,
      password: password,
    );

    return Response.json(
      statusCode: HttpStatus.ok,
      body: {
        'message': 'Login successful',
        'token': token,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}