import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:e_commerces/dto/AuthDto.dart';
import 'package:e_commerces/models/UserModel.dart';
import 'package:e_commerces/repositories/UserRepository.dart';
import 'package:e_commerces/services/UserService.dart';

class UserServiceImpl implements UserService {
  UserServiceImpl(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<UserDto> register(RegisterDto dto) async {
    final existingUser = await _userRepository.findByEmail(dto.email);
    if (existingUser != null) {
      throw Exception('User with this email already exists.');
    }

    final bytes = utf8.encode(dto.password);
    final passwordHash = sha256.convert(bytes).toString();

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: dto.name,
      email: dto.email,
      passwordHash: passwordHash,
    );

    await _userRepository.save(newUser);
    return UserDto.fromModel(newUser);
  }

  @override
  Future<String> login(LoginDto dto) async {
    final user = await _userRepository.findByEmail(dto.email);
    if (user == null) {
      throw Exception('Invalid email or password.');
    }

    final bytes = utf8.encode(dto.password);
    final inputHash = sha256.convert(bytes).toString();

    if (inputHash != user.passwordHash) {
      throw Exception('Invalid email or password.');
    }

    return 'mock-jwt-token-${user.id}';
  }

  @override
  Future<UserDto?> getById(String id) async {
    final user = await _userRepository.findById(id);
    if (user == null) return null;
    return UserDto.fromModel(user);
  }
}

