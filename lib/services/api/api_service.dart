import 'dart:convert';

import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract interface class ApiService {}

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

  /// throws [ApiException] :
  /// - [ApiTimeoutException] when the request times out;
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiEncodeRequestException] when there is a problem in encoding the request body;
  /// - [ApiDecodeResponseException] when there is a problem in decoding the response body;
  /// - default [ApiException] when an unknown error appears;
  Future<T> _request<T>({
    required String method,
    required String endpoint,
    required T Function(dynamic) parseResponse,
    Object Function()? parseRequest,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: parseRequest?.call(),
        options: Options(method: method),
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiUnauthorizedException();
      }
      return parseResponse(response.data);
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
