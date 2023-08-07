import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TokenRepository {
  Future<String?> retrieve();
  Future<void> save(String token);
  Future<void> clear();
}

final tokenRepositoryProvider = Provider((ref) {
  return TokenRepositoryImpl();
});

final class TokenRepositoryImpl implements TokenRepository {
  static const String _tokenKey = "token";

  @override
  Future<String?> retrieve() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, "");
  }
}
