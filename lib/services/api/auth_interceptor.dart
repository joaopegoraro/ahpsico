import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authService);

  final AuthService _authService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authService.getUserToken();
    if (token == null || token.idToken.isEmpty) {
      final message = "Invalid AuthToken: $token";
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: ApiUnauthorizedException(message: message),
        message: message,
      );
      return handler.reject(error);
    }

    options.headers.addAll({'Authorization': 'Bearer ${token.idToken}'});
    handler.next(options);
  }
}

final authInterceptorProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthInterceptor(authService);
});
