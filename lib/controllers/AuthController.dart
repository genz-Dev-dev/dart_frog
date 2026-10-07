import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../services/UserService.dart';
import '../repositories/UserRepository.dart';
import '../database/Mongodb.dart';

/// Handles all auth-related HTTP concerns:
/// - request parsing
/// - input validation
/// - delegating to [AuthService]
/// - building HTTP responses
class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  // ---------------------------------------------------------------------------
  // Factory — wires up the full dependency chain
  // ---------------------------------------------------------------------------
  static AuthController create() {
    final repo = UserRepository();
    final service = AuthService(repo);
    return AuthController(service);
  }

  // ---------------------------------------------------------------------------
  // POST /auth/register
  // ---------------------------------------------------------------------------
  Future<Response> register(RequestContext context) async {
    try {
      await MongoDatabase.connect();

      final body = await context.request.json() as Map<String, dynamic>;

      final name = body['name'] as String?;
      final email = body['email'] as String?;
      final password = body['password'] as String?;

      // --- Validation ---
      if (name == null || name.trim().isEmpty) {
        return _badRequest('Name is required.');
      }
      if (email == null || !email.contains('@')) {
        return _badRequest('A valid email is required.');
      }
      if (password == null || password.length < 6) {
        return _badRequest('Password must be at least 6 characters.');
      }

      // --- Delegate to service ---
      final user = await _authService.register(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'success': true,
          'message': 'Account created successfully.',
          'user': user.toJson(),
        },
      );
    } on FormatException {
      return _badRequest('Invalid JSON body.');
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'success': false, 'error': message},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // POST /auth/login
  // ---------------------------------------------------------------------------
  Future<Response> login(RequestContext context) async {
    try {
      await MongoDatabase.connect();

      final body = await context.request.json() as Map<String, dynamic>;

      final email = body['email'] as String?;
      final password = body['password'] as String?;

      // --- Validation ---
      if (email == null || email.trim().isEmpty) {
        return _badRequest('Email is required.');
      }
      if (password == null || password.isEmpty) {
        return _badRequest('Password is required.');
      }

      // --- Delegate to service ---
      final token = await _authService.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return Response.json(
        statusCode: HttpStatus.ok,
        body: {
          'success': true,
          'message': 'Login successful.',
          'token': token,
        },
      );
    } on FormatException {
      return _badRequest('Invalid JSON body.');
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'success': false, 'error': message},
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Response _badRequest(String message) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'success': false, 'error': message},
    );
  }
}

