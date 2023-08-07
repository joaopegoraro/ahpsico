import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesRepository {
  Future<String?> findUuid();
  Future<void> saveUuid(String uuid);
  Future<String?> findToken();
  Future<void> saveToken(String token);
  Future<void> clear();
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl();
});

final class PreferencesRepositoryImpl implements PreferencesRepository {
  static const String _tokenKey = "token";
  static const String _uuidKey = "uuid";

  @override
  Future<String?> findUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uuidKey);
  }

  @override
  Future<void> saveUuid(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_uuidKey, uuid);
  }

  @override
  Future<String?> findToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, "");
    prefs.setString(_uuidKey, "");
  }
}
