import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthService {
  Future<void> sendVerificationCode(String phoneNumber);
  Future<User> login(String phoneNumber, String code);
}

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthServiceImpl(apiService);
});

final class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<void> sendVerificationCode(String phoneNumber) async {
    return _apiService.sendVerificationCode(phoneNumber);
  }

  @override
  Future<User> login(String phoneNumber, String code) async {
    return _apiService.login(phoneNumber, code);
  }
}
