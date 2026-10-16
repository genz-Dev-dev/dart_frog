import 'package:e_commerces/models/UserModel.dart';

class RegisterDto {
  const RegisterDto({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  factory RegisterDto.fromJson(Map<String, dynamic> json) {
    return RegisterDto(
      name: json['name'].toString().trim(),
      email: json['email'].toString().trim().toLowerCase(),
      password: json['password'].toString(),
    );
  }
}

class LoginDto {
  const LoginDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      email: json['email'].toString().trim().toLowerCase(),
      password: json['password'].toString(),
    );
  }
}

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;

  factory UserDto.fromModel(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

