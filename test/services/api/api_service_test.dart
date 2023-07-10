import 'dart:convert';

import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  final mockDio = MockDio();
  final ApiService apiService = ApiServiceImpl(mockDio);
  final ApiServiceImpl apiServiceImpl = apiService as ApiServiceImpl;

  setUp(() {});

  group("request", () {
    test("Response with error code should throw ApiException if no parseFailure has been provided", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      final decodedBody = json.decode(bodyJson) as Map<String, dynamic>;
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(data: bodyJson, statusCode: 404, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiException catch (e) {
        assert(e.message == decodedBody.toString());
        assert(e.code == null);
      }
    });
    test(
        "Response with error code should throw ApiException if no parseFailure has been provided and decoding of error body fails",
        () async {
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(statusCode: 404, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiException catch (e) {
        assert(e.message != null);
        assert(e.code == null);
      }
    });

    test("Response with status 400 throws ApiBadRequestException", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      final decodedBody = json.decode(bodyJson) as Map<String, dynamic>;
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(data: bodyJson, statusCode: 400, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiBadRequestException catch (e) {
        final expectedException = ApiBadRequestException(message: decodedBody.toString());
        assert(e.message == expectedException.message);
      }
    });

    test("Response with status 401 throws ApiUnauthorizedException", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(data: bodyJson, statusCode: 401, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiUnauthorizedException catch (_) {
        assert(true);
      }
    });

    test("Response with status 403 throws ApiUnauthorizedException", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(data: bodyJson, statusCode: 403, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiUnauthorizedException catch (_) {
        assert(true);
      }
    });

    test("Response with connection timeout throws ApiTimeoutException", () async {
      const message = "timeout";
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        throw DioException(
          message: message,
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        );
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiTimeoutException catch (e) {
        const expectedException = ApiTimeoutException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with send timeout throws ApiTimeoutException", () async {
      const message = "timeout";
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        throw DioException(
          message: message,
          requestOptions: RequestOptions(),
          type: DioExceptionType.sendTimeout,
        );
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiTimeoutException catch (e) {
        const expectedException = ApiTimeoutException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with receive timeout throws ApiTimeoutException", () async {
      const message = "timeout";
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        throw DioException(
          message: message,
          requestOptions: RequestOptions(),
          type: DioExceptionType.receiveTimeout,
        );
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiTimeoutException catch (e) {
        const expectedException = ApiTimeoutException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with connection error throws ApiConnectionException", () async {
      const message = "timeout";
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        throw DioException(
          message: message,
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        );
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiConnectionException catch (e) {
        const expectedException = ApiConnectionException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with unknown dio exception throws ApiException", () async {
      const message = "timeout";
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        throw DioException(message: message, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiException catch (e) {
        const expectedException = ApiException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Error encoding request throws ApiEncodeRequestException", () async {
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(statusCode: 200, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          requestBody: () {
            throw JsonUnsupportedObjectError(null);
          },
          parseSuccess: (_) {},
        );
        assert(false);
      } on ApiEncodeRequestException catch (_) {
        assert(true);
      }
    });

    test("Error decoding response throws ApiDecodeResponseException", () async {
      const message = "timeout";
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(statusCode: 200, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {
            throw const FormatException(message);
          },
        );
      } on ApiDecodeResponseException catch (e) {
        const expectedException = ApiDecodeResponseException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Error typing decoded response throws ApiDecodeResponseException", () async {
      when(
        () => mockDio.request(
          any(),
          data: any(named: "data"),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer((_) async {
        return Response(statusCode: 200, requestOptions: RequestOptions());
      });
      try {
        await apiServiceImpl.request(
          method: 'GET',
          endpoint: 'something',
          parseSuccess: (_) {
            throw TypeError();
          },
        );
      } on ApiDecodeResponseException catch (_) {
        assert(true);
      }
    });
  });
}
