import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/logger/logging_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._preferencesRepository, this._logger);

  final PreferencesRepository _preferencesRepository;
  final LoggingService _logger;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (["verification-code", "login"].contains(options.path)) {
      _logger.w("Non auth endpoint ${options.path}");
      return handler.next(options);
    }
    final token = await _preferencesRepository.findToken();
    if (token == null || token.isEmpty) {
      _logger.w("Empty or null token: $token");
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
    _logger.w("Sending token $token");
    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      final token = response.headers.value("token");
      await _preferencesRepository.saveToken(token ?? "");
      _logger.w("Saving token $token");
    } catch (e) {
      _logger.e("onResponse token retrieving error", e);
    }

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
        _logger.w("Saving token $token");
      } catch (e) {
        _logger.e("onError token retrieving error", e);
      }
    }
    super.onError(err, handler);
  }
}

final authInterceptorProvider = Provider((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return AuthInterceptor(preferencesRepository, logger);
});
