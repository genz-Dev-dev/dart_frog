import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/repositories/UserRepository.dart';
import '../../lib/services/UserService.dart';
import '../../lib/database/Mongodb.dart';

// Singleton instances
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
    final name = body['name'] as String?;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (name == null || email == null || password == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Name, email, and password are required.'},
      );
    }

    final user = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'message': 'Account created successfully',
        'user': user.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': e.toString().replaceAll('Exception: ', '')},
    );
  }
}