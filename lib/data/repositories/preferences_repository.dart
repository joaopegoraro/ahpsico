import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesRepository {
  Future<int?> findId();
  Future<void> saveId(int id);
  Future<String?> findToken();
  Future<void> saveToken(String token);
  Future<void> clear();
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl();
});

final class PreferencesRepositoryImpl implements PreferencesRepository {
  static const String _tokenKey = "token";
  static const String _idKey = "id";

  @override
  Future<int?> findId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idKey);
  }

  @override
  Future<void> saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_idKey, id);
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
    prefs.remove(_idKey);
  }
}
