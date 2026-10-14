import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/services/UserService.dart';
import 'package:e_commerces/repositories/UserRepository.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

/// Handles all auth-related HTTP concerns:
/// - request parsing
/// - input validation
/// - delegating to [AuthService]
/// - building HTTP responses via [ApiResponse]
class AuthController {

  AuthController(this._authService);
  final AuthService _authService;

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
        return ApiResponse.badRequest('Name is required.');
      }
      if (email == null || !email.contains('@')) {
        return ApiResponse.badRequest('A valid email is required.');
      }
      if (password == null || password.length < 6) {
        return ApiResponse.badRequest(
            'Password must be at least 6 characters.');
      }

      // --- Delegate to service ---
      final user = await _authService.register(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );

      return ApiResponse.created(
        data: user.toJson(),
        message: 'Account created successfully.',
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      return ApiResponse.badRequest(ApiResponse.cleanError(e));
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
        return ApiResponse.badRequest('Email is required.');
      }
      if (password == null || password.isEmpty) {
        return ApiResponse.badRequest('Password is required.');
      }

      // --- Delegate to service ---
      final token = await _authService.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return ApiResponse.single(
        data: {'token': token},
        message: 'Login successful.',
      );
    } on FormatException {
      return ApiResponse.badRequest('Invalid JSON body.');
    } catch (e) {
      return ApiResponse.unauthorized(ApiResponse.cleanError(e));
    }
  }
}
