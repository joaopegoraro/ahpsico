import 'dart:convert';

import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// All service methods can throw [ApiException] :
/// - [ApiTimeoutException] when the request times out;
/// - [ApiConnectionException] when the request suffers any connection problems;
/// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
/// - [ApiBadRequestException] when the response returns a status of 400;
/// - [ApiEncodeRequestException] when there is a problem in encoding the request body;
/// - [ApiDecodeResponseException] when there is a problem in decoding the response body;
/// - default [ApiException] when an unknown error appears;
abstract interface class ApiService {
  /// throws [ApiUserNotRegisteredException] when the user trying to login is
  /// not yet registered.
  ///
  /// The login credential is the [AuthToken] that is passed
  /// in the headers.

  /// Returns the user data
  Future<User> login();

  /// throws [ApiUserAlreadyRegisteredException] when the user trying to sign up is
  /// already registered.

  /// Returns the user data
  Future<User> signUp();
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final options = BaseOptions(baseUrl: dotenv.env['BASE_URL']!);
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggerInterceptor = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  );
  final dio = Dio(options)..interceptors.addAll([authInterceptor, loggerInterceptor]);
  return ApiServiceImpl(dio);
});

class ApiServiceImpl implements ApiService {
  ApiServiceImpl(this._dio);

  final Dio _dio;

  /// throws [ApiUserNotRegisteredException] when the user trying to login is
  /// not yet registered.
  ///
  /// The login credential is the [AuthToken] that is passed
  /// in the headers.
  ///
  /// Returns the user data
  @override
  Future<User> login() async {
    return await _request(
      method: "POST",
      endpoint: "login",
      parseResponse: (response) {
        if (response.statusCode == 406) {
          throw const ApiUserNotRegisteredException();
        }
        return User.fromJson(response.data);
      },
    );
  }

  /// throws [ApiUserAlreadyRegisteredException] when the user trying to sign up is
  /// already registered.

  /// Returns the user data
  @override
  Future<User> signUp() async {
    return await _request(
      method: "POST",
      endpoint: "signup",
      parseResponse: (response) {
        if (response.statusCode == 406) {
          throw const ApiUserAlreadyRegisteredException();
        }
        return User.fromJson(response.data);
      },
    );
  }

  /// throws [ApiException] :
  /// - [ApiTimeoutException] when the request times out;
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  /// - [ApiBadRequestException] when the response returns a status of 400;
  /// - [ApiEncodeRequestException] when there is a problem in encoding the request body;
  /// - [ApiDecodeResponseException] when there is a problem in decoding the response body;
  /// - default [ApiException] when an unknown error appears;
  Future<T> _request<T>({
    required String method,
    required String endpoint,
    required T Function(Response) parseResponse,
    Object Function()? parseRequest,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: parseRequest?.call(),
        options: Options(method: method),
      );
      switch (response.statusCode) {
        case 400:
          final errorBody = json.decode(response.data) as Map<String, dynamic>;
          throw ApiBadRequestException(message: errorBody.toString());
        case 401:
        case 403:
          throw const ApiUnauthorizedException();
      }
      return parseResponse(response);
    } on DioException catch (e, stackTrace) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          ApiTimeoutException(message: e.message).throwWithStackTrace(stackTrace);
        case DioExceptionType.connectionError:
          ApiConnectionException(message: e.message).throwWithStackTrace(stackTrace);
        default:
          ApiException(message: e.message).throwWithStackTrace(stackTrace);
      }
    } on JsonUnsupportedObjectError catch (e, stackTrace) {
      const ApiEncodeRequestException().throwWithStackTrace(stackTrace);
    } on FormatException catch (e, stackTrace) {
      ApiDecodeResponseException(message: e.message).throwWithStackTrace(stackTrace);
    }
  }
}
