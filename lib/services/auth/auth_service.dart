import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class AuthService {
  Future<ApiError?> sendVerificationCode(String phoneNumber);
  Future<(User?, ApiError?)> login(String phoneNumber, String code);
  Future<void> signOut();
}

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return AuthServiceImpl(apiService, preferencesRepository, database);
});

final class AuthServiceImpl implements AuthService {
  AuthServiceImpl(
    this._apiService,
    this._preferencesRepository,
    this._db,
  );

  final ApiService _apiService;
  final PreferencesRepository _preferencesRepository;
  final sqflite.Database _db;

  @override
  Future<ApiError?> sendVerificationCode(String phoneNumber) async {
    return await _apiService.sendVerificationCode(phoneNumber);
  }

  @override
  Future<(User?, ApiError?)> login(String phoneNumber, String code) async {
    return await _apiService.login(phoneNumber, code);
  }

  @override
  Future<void> signOut() async {
    for (final table in AhpsicoDatabase.tables) {
      await _db.rawDelete("DELETE FROM $table");
    }
    return await _preferencesRepository.clear();
  }
}
