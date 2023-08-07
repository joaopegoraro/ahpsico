import 'package:ahpsico/data/repositories/token_repository.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenRepository);

  final TokenRepository _tokenRepository;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenRepository.retrieve();
    if (token == null || token.isEmpty) {
      final message = "Invalid AuthToken: $token";
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: ApiUnauthorizedException(message: message),
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
      final token = response.headers["token"] as String?;
      await _tokenRepository.save(token ?? "");
    } catch (_) {}

    handler.next(response);
  }
}

final authInterceptorProvider = Provider((ref) {
  final tokenRepository = ref.watch(tokenRepositoryProvider);
  return AuthInterceptor(tokenRepository);
});
