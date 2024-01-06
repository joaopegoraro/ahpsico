import 'dart:io';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/constants/user_role.dart';
import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/models/message.dart';
import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/logger/logging_service.dart';
import 'package:ahpsico/utils/time_utils.dart';
import 'package:ahpsico/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract interface class ApiService {
  Future<ApiError?> sendVerificationCode(String phoneNumber);

  Future<(User?, ApiError?)> login(String phoneNumber, String code);

  Future<(User?, ApiError?)> signUp(String userName, UserRole role);

  Future<(User?, ApiError?)> getUser(int id);

  Future<(User?, ApiError?)> updateUser(User user);

  Future<(List<User>?, ApiError?)> getPatients();

  Future<(List<Session>?, ApiError?)> getDoctorSessions({DateTime? date});

  Future<(List<Session>?, ApiError?)> getPatientSessions(
    int patientId, {
    bool? upcoming,
  });

  Future<(List<Assignment>?, ApiError?)> getPatientAssignments(
    int patientId, {
    bool? pending,
  });

  Future<(List<Message>?, ApiError?)> getDoctorMessages();

  Future<(List<Message>?, ApiError?)> getPatientMessages(int patientId);

  Future<(Session?, ApiError?)> getSession(int id);

  Future<(Session?, ApiError?)> createSession(Session session);

  Future<(Session?, ApiError?)> updateSession(Session session);

  Future<(Assignment?, ApiError?)> createAssignment(Assignment assignment);

  Future<(Assignment?, ApiError?)> updateAssignment(Assignment assignment);

  Future<ApiError?> deleteAssignment(int id);

  Future<(Message?, ApiError?)> createMessage(
    Message message, {
    required List<int> userIds,
  });

  Future<ApiError?> deleteMessage(int id);
}

final apiServiceProvider = Provider<ApiService>((ref) {
  const timeout = Duration(seconds: 30);
  final options = BaseOptions(
      baseUrl: dotenv.env['BASE_URL']!,
      sendTimeout: timeout,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      contentType: "application/json");
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggerInterceptor = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
  );
  final dio = Dio(options)
    ..interceptors.addAll([authInterceptor, loggerInterceptor]);
  final logger = ref.watch(loggerProvider);
  return ApiServiceImpl(dio, logger);
});

class ApiServiceImpl implements ApiService {
  ApiServiceImpl(this._dio, this._logger);

  final Dio _dio;
  final LoggingService _logger;

  @override
  Future<ApiError?> sendVerificationCode(String phoneNumber) async {
    final (_, err) = await request(
      method: "POST",
      endpoint: "verification-code",
      requestBody: () => <String, dynamic>{
        "phoneNumber": phoneNumber,
      },
      parseSuccess: (response) {/* SUCCESS! */},
    );
    return err;
  }

  @override
  Future<(User?, ApiError?)> login(String phoneNumber, String code) async {
    return await request(
      method: "POST",
      endpoint: "login",
      requestBody: () => <String, dynamic>{
        "phoneNumber": phoneNumber,
        "code": code,
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return User.fromMap(map);
      },
      parseFailure: (response) {
        if (response?.statusCode == 406) {
          return const ApiUserNotRegisteredError();
        }
        return null;
      },
    );
  }

  @override
  Future<(User?, ApiError?)> signUp(String userName, UserRole role) async {
    return await request(
      method: "POST",
      endpoint: "signup",
      requestBody: () => <String, dynamic>{
        "name": userName,
        "role": role.value,
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return User.fromMap(map);
      },
      parseFailure: (response) {
        if (response?.statusCode == 406) {
          return const ApiUserAlreadyRegisteredError();
        }
        return null;
      },
    );
  }

  @override
  Future<(User?, ApiError?)> getUser(int id) async {
    return await request(
      method: "GET",
      endpoint: "users/$id",
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return User.fromMap(map);
      },
    );
  }

  @override
  Future<(User?, ApiError?)> updateUser(User user) async {
    return await request(
      method: "PUT",
      endpoint: "users/${user.id}",
      requestBody: () {
        return user.toMap();
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return User.fromMap(map);
      },
    );
  }

  @override
  Future<(List<User>?, ApiError?)> getPatients() async {
    return await request(
      method: "GET",
      endpoint: "patients",
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => User.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Session>?, ApiError?)> getDoctorSessions({
    DateTime? date,
  }) async {
    return await request(
      method: "GET",
      endpoint: "sessions",
      buildQueryParameters: () {
        if (date == null) return null;
        return {
          "date":
              TimeUtils.formatDateWithOffset(date, AppConstants.datePattern),
        };
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Message>?, ApiError?)> getDoctorMessages() async {
    return await request(
      method: "GET",
      endpoint: "advices",
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Message.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Session>?, ApiError?)> getPatientSessions(
    int patientId, {
    bool? upcoming,
  }) async {
    return await request(
      method: "GET",
      endpoint: "sessions",
      buildQueryParameters: () => <String, dynamic>{
        "patientId": patientId,
        "upcoming": upcoming,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Assignment>?, ApiError?)> getPatientAssignments(
    int patientId, {
    bool? pending,
  }) async {
    return await request(
      method: "GET",
      endpoint: "assignments",
      buildQueryParameters: () => <String, dynamic>{
        "patientId": patientId,
        "pending": pending,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Assignment.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Message>?, ApiError?)> getPatientMessages(
    int patientId,
  ) async {
    return await request(
      method: "GET",
      endpoint: "advices",
      buildQueryParameters: () => <String, dynamic>{
        "patientId": patientId,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Message.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(Session?, ApiError?)> getSession(int id) async {
    return await request(
      method: "GET",
      endpoint: "sessions/$id",
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return Session.fromMap(map);
      },
    );
  }

  @override
  Future<(Session?, ApiError?)> createSession(Session session) async {
    return await request(
      method: "POST",
      endpoint: "sessions",
      requestBody: session.toMap,
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return session.copyWith(id: map["id"]);
      },
      parseFailure: (response) {
        if (response?.statusCode == 409) {
          return const ApiSessionAlreadyBookedError();
        }
        return null;
      },
    );
  }

  @override
  Future<(Session?, ApiError?)> updateSession(Session session) async {
    return await request(
      method: "PUT",
      endpoint: "sessions/${session.id}",
      requestBody: session.toMap,
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return session.copyWith(id: map["id"]);
      },
      parseFailure: (response) {
        if (response?.statusCode == 409) {
          return const ApiSessionAlreadyBookedError();
        }
        return null;
      },
    );
  }

  @override
  Future<(Assignment?, ApiError?)> createAssignment(
      Assignment assignment) async {
    return await request(
      method: "POST",
      endpoint: "assignments",
      requestBody: assignment.toMap,
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return assignment.copyWith(id: map["id"]);
      },
    );
  }

  @override
  Future<(Assignment?, ApiError?)> updateAssignment(
      Assignment assignment) async {
    return await request(
      method: "PUT",
      endpoint: "assignments/${assignment.id}",
      requestBody: assignment.toMap,
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return assignment.copyWith(id: map["id"]);
      },
    );
  }

  @override
  Future<ApiError?> deleteAssignment(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "assignments/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
    return err;
  }

  @override
  Future<(Message?, ApiError?)> createMessage(
    Message message, {
    required List<int> userIds,
  }) async {
    return await request(
      method: "POST",
      endpoint: "advices",
      requestBody: () {
        return message.toMap().addAll({"userIds": userIds});
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return Message.fromMap(map);
      },
    );
  }

  @override
  Future<ApiError?> deleteMessage(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "advices/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
    return err;
  }

  @visibleForTesting
  Future<(T?, ApiError?)> request<T>({
    required String method,
    required String endpoint,
    required T Function(Response response) parseSuccess,
    ApiError? Function(Response? response)? parseFailure,
    Object? Function()? requestBody,
    Map<String, dynamic>? Function()? buildQueryParameters,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: requestBody?.call(),
        queryParameters: buildQueryParameters?.call(),
        options: Options(method: method),
      );

      return (parseSuccess(response), null);
    } on DioException catch (e, stackTrace) {
      if (e.error is ApiError) return (null, e.error as ApiError);
      switch (e.type) {
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          _logger.e("Dio Unknown error", e, stackTrace);

          if (e.error is SocketException) {
            return (null, ApiConnectionError(message: e.message));
          }

          switch (e.response?.statusCode) {
            case 400:
              return (null, const ApiBadRequestError());
            case 401:
              return (null, const ApiUnauthorizedError());
          }

          final failure = parseFailure?.call(e.response);
          if (failure != null) {
            return (null, failure);
          }

          return (null, ApiError(code: "Status: ${e.response?.statusCode}"));
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        default:
          return (null, ApiConnectionError(message: e.message));
      }
    } catch (e, stackTrace) {
      _logger.e("Unknown error", e, stackTrace);
      return (null, ApiError(message: e.toString()));
    }
  }
}
