import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/services/auth/token.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  final mockAuthService = MockAuthService();
  final mockRequestInterceptorHandler = MockRequestInterceptorHandler();
  final authInterceptor = AuthInterceptor(mockAuthService);

  setUp(() {
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
    registerFallbackValue(RequestOptions());
  });

  test("null auth token rejects the request with ApiUnauthorizedException", () async {
    final options = RequestOptions();
    const AuthToken? token = null;
    const expectedError = ApiUnauthorizedException(message: "Invalid AuthToken: $token");
    when(mockAuthService.getUserToken).thenAnswer((_) async => null);
    await authInterceptor.onRequest(options, mockRequestInterceptorHandler);
    verifyNever(() => mockRequestInterceptorHandler.next(any()));
    final captured = verify(() => mockRequestInterceptorHandler.reject(captureAny())).captured;
    final error = captured.first as DioException;
    final apiException = error.error as ApiException;
    assert(apiException.message == expectedError.message);
    assert(apiException.code == expectedError.code);
  });

  test("empty auth token rejects the request with ApiUnauthorizedException", () async {
    final options = RequestOptions();
    const token = AuthToken("");
    final expectedError = ApiUnauthorizedException(message: "Invalid AuthToken: $token");
    when(() => mockAuthService.getUserToken()).thenAnswer((_) async => token);
    await authInterceptor.onRequest(options, mockRequestInterceptorHandler);
    verifyNever(() => mockRequestInterceptorHandler.next(any()));
    final captured = verify(() => mockRequestInterceptorHandler.reject(captureAny())).captured;
    final error = captured.first as DioException;
    final apiException = error.error as ApiException;
    assert(apiException.message == expectedError.message);
    assert(apiException.code == expectedError.code);
  });

  test("valid auth token accepts the request with authorizer headers", () async {
    final options = RequestOptions();
    const token = AuthToken("some token");
    final Map<String, dynamic> headers = {'Authorization': 'Bearer ${token.idToken}'};
    when(mockAuthService.getUserToken).thenAnswer((_) async => token);
    await authInterceptor.onRequest(options, mockRequestInterceptorHandler);
    verifyNever(() => mockRequestInterceptorHandler.reject(any()));
    verify(() => mockRequestInterceptorHandler.next(options));
    assert(const DeepCollectionEquality().equals(options.headers, headers));
  });
}
