import 'package:dart_frog/dart_frog.dart';
import 'package:e_commerces/database/Mongodb.dart';
import 'package:e_commerces/dto/AuthDto.dart';
import 'package:e_commerces/repositories/UserRepository.dart';
import 'package:e_commerces/services/UserService.dart';
import 'package:e_commerces/services/serviceImplementation/UserServiceImpl.dart';
import 'package:e_commerces/utils/ApiResponse.dart';

class AuthController {
  AuthController(this._userService);
  final UserService _userService;

  static AuthController create() {
    final repo = UserRepository();
    final service = UserServiceImpl(repo);
    return AuthController(service);
  }

  // ---------------------------------------------------------------------------
  // POST /auth/register
  // ---------------------------------------------------------------------------
  Future<Response> register(RequestContext context) async {
    try {
      await MongoDatabase.connect();

      final body = await context.request.json() as Map<String, dynamic>;

      final name = body['name']?.toString().trim();
      final email = body['email']?.toString().trim();
      final password = body['password']?.toString();

      // --- Validation ---
      if (name == null || name.isEmpty) {
        return ApiResponse.badRequest('Name is required.');
      }
      if (email == null || !email.contains('@')) {
        return ApiResponse.badRequest('A valid email is required.');
      }
      if (password == null || password.length < 6) {
        return ApiResponse.badRequest(
          'Password must be at least 6 characters.',
        );
      }

      final dto = RegisterDto.fromJson(body);
      final user = await _userService.register(dto);

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

      final email = body['email']?.toString().trim();
      final password = body['password']?.toString();

      // --- Validation ---
      if (email == null || email.isEmpty) {
        return ApiResponse.badRequest('Email is required.');
      }
      if (password == null || password.isEmpty) {
        return ApiResponse.badRequest('Password is required.');
      }

      final dto = LoginDto.fromJson(body);
      final token = await _userService.login(dto);

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
