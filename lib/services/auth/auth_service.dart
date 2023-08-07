import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthService {
  Future<ApiException?> sendVerificationCode(String phoneNumber);
  Future<(User?, ApiException?)> login(String phoneNumber, String code);
  Future<void> signOut();
}

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return AuthServiceImpl(apiService, preferencesRepository);
});

final class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._apiService, this._preferencesRepository);

  final ApiService _apiService;
  final PreferencesRepository _preferencesRepository;

  @override
  Future<ApiException?> sendVerificationCode(String phoneNumber) async {
    return await _apiService.sendVerificationCode(phoneNumber);
  }

  @override
  Future<(User?, ApiException?)> login(String phoneNumber, String code) async {
    return await _apiService.login(phoneNumber, code);
  }

  @override
  Future<void> signOut() async {
    return await _preferencesRepository.clear();
  }
}
