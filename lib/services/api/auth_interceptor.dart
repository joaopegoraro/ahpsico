import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._preferencesRepository);

  final PreferencesRepository _preferencesRepository;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (["verification-code", "login"].contains(options.path)) {
      return handler.next(options);
    }
    final token = await _preferencesRepository.findToken();
    if (token == null || token.isEmpty) {
      final message = "Invalid AuthToken: $token";
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: ApiUnauthorizedError(message: message),
        message: message,
      );
      return handler.reject(error);
    }

    options.headers.addAll({'Authorization': 'Bearer $token'});
    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      final token = response.headers.value("token");
      await _preferencesRepository.saveToken(token ?? "");
    } catch (_) {}

    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response?.statusCode == null) return super.onError(err, handler);
    if (response!.statusCode! < 500 && response.statusCode != 401) {
      try {
        final token = response.headers.value("token");
        await _preferencesRepository.saveToken(token ?? "");
      } catch (_) {}
    }
    super.onError(err, handler);
  }
}

final authInterceptorProvider = Provider((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return AuthInterceptor(preferencesRepository);
});
