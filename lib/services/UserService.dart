import 'package:e_commerces/dto/AuthDto.dart';

abstract class UserService {
  Future<UserDto> register(RegisterDto dto);
  Future<String> login(LoginDto dto);
  Future<UserDto?> getById(String id);
}