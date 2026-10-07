import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/UserModel.dart';
import '../repositories/UserRepository.dart';

class AuthService {
  final UserRepository _userRepository;

  AuthService(this._userRepository);

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Check if user already exists
    final existingUser = await _userRepository.findByEmail(email);
    if (existingUser != null) {
      throw Exception('User with this email already exists.');
    }

    // Hash password
    final bytes = utf8.encode(password);
    final passwordHash = sha256.convert(bytes).toString();

    // Create user model
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      passwordHash: passwordHash,
    );

    await _userRepository.save(newUser);
    return newUser;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final user = await _userRepository.findByEmail(email);
    if (user == null) {
      throw Exception('Invalid email or password.');
    }

    // Verify password
    final bytes = utf8.encode(password);
    final inputHash = sha256.convert(bytes).toString();

    if (inputHash != user.passwordHash) {
      throw Exception('Invalid email or password.');
    }

    // Return a mock JWT token (replace with a real token generator package)
    return 'mock-jwt-token-${user.id}';
  }
}