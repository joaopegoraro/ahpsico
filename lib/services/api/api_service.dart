import 'dart:io';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/models/advice.dart';
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

  Future<(Invite?, ApiError?)> createInvite(String phoneNumber);

  Future<(List<Invite>?, ApiError?)> getInvites();

  Future<ApiError?> deleteInvite(int id);

  Future<ApiError?> acceptInvite(int id);

  Future<(User?, ApiError?)> getUser(String uuid);

  Future<(User?, ApiError?)> updateUser(User user);

  Future<(List<User>?, ApiError?)> getDoctorPatients(String doctorId);

  Future<(List<Session>?, ApiError?)> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  Future<(List<Advice>?, ApiError?)> getDoctorAdvices(String doctorId);

  Future<(List<Schedule>?, ApiError?)> getDoctorSchedule(String doctorId);

  Future<(List<User>?, ApiError?)> getPatientDoctors(String patientId);

  Future<(List<Session>?, ApiError?)> getPatientSessions(
    String patientId, {
    bool? upcoming,
  });

  Future<(List<Assignment>?, ApiError?)> getPatientAssignments(
    String patientId, {
    bool? pending,
  });

  Future<(List<Advice>?, ApiError?)> getPatientAdvices(String patientId);

  Future<(Session?, ApiError?)> getSession(int id);

  Future<(Session?, ApiError?)> createSession(Session session);

  Future<(Session?, ApiError?)> updateSession(Session session);

  Future<(Assignment?, ApiError?)> createAssignment(Assignment assignment);

  Future<(Assignment?, ApiError?)> updateAssignment(Assignment assignment);

  Future<ApiError?> deleteAssignment(int id);

  Future<(Advice?, ApiError?)> createAdvice(Advice advice);

  Future<ApiError?> deleteAdvice(int id);

  Future<(Schedule?, ApiError?)> createSchedule(Schedule schedule);

  Future<ApiError?> deleteSchedule(int id);
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
  final dio = Dio(options)..interceptors.addAll([authInterceptor, loggerInterceptor]);
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
  Future<(Invite?, ApiError?)> createInvite(String phoneNumber) async {
    return await request(
      method: "POST",
      endpoint: "invites",
      requestBody: () => <String, dynamic>{
        "phoneNumber": phoneNumber,
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return Invite.fromMap(map);
      },
      parseFailure: (response) {
        switch (response?.statusCode) {
          case 404:
            return const ApiPatientNotRegisteredError();
          case 409:
            final errorBody = Utils.castToJsonMap(response!.data);
            final errorCode = errorBody['type'] as String?;
            switch (errorCode) {
              case "invite_already_sent":
                return const ApiInviteAlreadySentError();
              case "patient_already_with_doctor":
                return const ApiPatientAlreadyWithDoctorError();
              default:
                return null;
            }
          default:
            return null;
        }
      },
    );
  }

  @override
  Future<(List<Invite>?, ApiError?)> getInvites() async {
    return await request(
      method: "GET",
      endpoint: "invites",
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Invite.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<ApiError?> deleteInvite(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "invites/$id",
      parseSuccess: (response) {/* SUCCESS! */},
    );
    return err;
  }

  @override
  Future<ApiError?> acceptInvite(int id) async {
    final (_, err) = await request(
      method: "POST",
      endpoint: "invites/$id/accept",
      parseSuccess: (response) {/* SUCCESS! */},
    );
    return err;
  }

  @override
  Future<(User?, ApiError?)> getUser(String uuid) async {
    return await request(
      method: "GET",
      endpoint: "users/$uuid",
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
      endpoint: "users/${user.uuid}",
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
  Future<(List<User>?, ApiError?)> getDoctorPatients(String doctorUuid) async {
    return await request(
      method: "GET",
      endpoint: "patients",
      buildQueryParameters: () => <String, dynamic>{
        "doctorUuid": doctorUuid,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => User.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Session>?, ApiError?)> getDoctorSessions(
    String doctorUuid, {
    DateTime? date,
  }) async {
    return await request(
      method: "GET",
      endpoint: "sessions",
      buildQueryParameters: () {
        if (date == null) return {"doctorUuid": doctorUuid};
        return {
          "date": TimeUtils.formatDateWithOffset(date, AppConstants.datePattern),
          "doctorUuid": doctorUuid,
        };
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Advice>?, ApiError?)> getDoctorAdvices(String doctorUuid) async {
    return await request(
      method: "GET",
      endpoint: "advices",
      buildQueryParameters: () => <String, dynamic>{
        "doctorUuid": doctorUuid,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Advice.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Schedule>?, ApiError?)> getDoctorSchedule(String doctorUuid) async {
    return await request(
      method: "GET",
      endpoint: "schedule",
      buildQueryParameters: () => <String, dynamic>{
        "doctorUuid": doctorUuid,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Schedule.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<User>?, ApiError?)> getPatientDoctors(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "doctors",
      buildQueryParameters: () => <String, dynamic>{
        "patientUuid": patientId,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => User.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Session>?, ApiError?)> getPatientSessions(
    String patientId, {
    bool? upcoming,
  }) async {
    return await request(
      method: "GET",
      endpoint: "sessions",
      buildQueryParameters: () => <String, dynamic>{
        "patientUuid": patientId,
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
    String patientId, {
    bool? pending,
  }) async {
    return await request(
      method: "GET",
      endpoint: "assignments",
      buildQueryParameters: () => <String, dynamic>{
        "patientUuid": patientId,
        "pending": pending,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Assignment.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Advice>?, ApiError?)> getPatientAdvices(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "advices",
      buildQueryParameters: () => <String, dynamic>{
        "patientUuid": patientId,
      },
      parseSuccess: (response) {
        final list = Utils.castToJsonList(response.data);
        return list.map((e) => Advice.fromMap(e)).toList();
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
      requestBody: () => <String, dynamic>{
        "doctorUuid": session.doctor.uuid,
        "patientUuid": session.patient.uuid,
        "groupIndex": session.groupIndex,
        "status": session.status.value,
        "paymentStatus": session.paymentStatus.value,
        "type": session.type.value,
        "date": TimeUtils.formatDateWithOffset(session.date, AppConstants.datePattern),
      },
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
      requestBody: () => <String, dynamic>{
        "status": session.status.value,
        "paymentStatus": session.paymentStatus.value,
        "date": TimeUtils.formatDateWithOffset(session.date, AppConstants.datePattern),
      },
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
  Future<(Assignment?, ApiError?)> createAssignment(Assignment assignment) async {
    return await request(
      method: "POST",
      endpoint: "assignments",
      requestBody: () => <String, dynamic>{
        "doctorUuid": assignment.doctor.uuid,
        "patientUuid": assignment.patientId,
        "deliverySessionId": assignment.deliverySession.id,
        "title": assignment.title,
        "description": assignment.description,
        "status": assignment.status.value,
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return assignment.copyWith(id: map["id"]);
      },
    );
  }

  @override
  Future<(Assignment?, ApiError?)> updateAssignment(Assignment assignment) async {
    return await request(
      method: "PUT",
      endpoint: "assignments/${assignment.id}",
      requestBody: () => <String, dynamic>{
        "title": assignment.title,
        "description": assignment.description,
        "status": assignment.status.value,
      },
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
  Future<(Advice?, ApiError?)> createAdvice(Advice advice) async {
    return await request(
      method: "POST",
      endpoint: "advices",
      requestBody: () => <String, dynamic>{
        "doctorUuid": advice.doctor.uuid,
        "message": advice.message,
        "patientUuids": advice.patientIds,
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return Advice.fromMap(map);
      },
    );
  }

  @override
  Future<ApiError?> deleteAdvice(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "advices/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
    return err;
  }

  @override
  Future<(Schedule?, ApiError?)> createSchedule(Schedule schedule) async {
    return await request(
      method: "POST",
      endpoint: "schedule",
      requestBody: () {
        return schedule.toMap();
      },
      parseSuccess: (response) {
        final map = Utils.castToJsonMap(response.data);
        return Schedule.fromMap(map);
      },
    );
  }

  @override
  Future<ApiError?> deleteSchedule(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "schedule/$id",
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
