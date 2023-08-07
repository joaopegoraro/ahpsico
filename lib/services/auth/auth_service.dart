import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthService {
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  /// - [ApiBadRequestException] when the response returns a status of 400;
  ///
  /// Sends the verification code to the provided [phoneNumber]
  Future<void> sendVerificationCode(String phoneNumber);
  Future<User> login(String phoneNumber, String code);
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
  Future<void> sendVerificationCode(String phoneNumber) async {
    return await _apiService.sendVerificationCode(phoneNumber);
  }

  @override
  Future<User> login(String phoneNumber, String code) async {
    return await _apiService.login(phoneNumber, code);
  }

  @override
  Future<void> signOut() async {
    return await _preferencesRepository.clear();
  }
}
