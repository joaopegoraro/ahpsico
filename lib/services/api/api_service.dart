import 'dart:convert';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract interface class ApiService {
  Future<ApiException?> sendVerificationCode(String phoneNumber);

  Future<(User?, ApiException?)> login(String phoneNumber, String code);

  Future<(User?, ApiException?)> signUp(String userName, UserRole role);

  Future<(Invite?, ApiException?)> createInvite(String phoneNumber);

  Future<(List<Invite>?, ApiException?)> getInvites();

  Future<ApiException?> deleteInvite(int id);

  Future<ApiException?> acceptInvite(int id);

  Future<(User?, ApiException?)> getUser(String uuid);

  Future<(User?, ApiException?)> updateUser(User user);

  Future<(List<User>?, ApiException?)> getDoctorPatients(String doctorId);

  Future<(List<Session>?, ApiException?)> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  Future<(List<Advice>?, ApiException?)> getDoctorAdvices(String doctorId);

  Future<(List<Schedule>?, ApiException?)> getDoctorSchedule(String doctorId);

  Future<(List<User>?, ApiException?)> getPatientDoctors(String patientId);

  Future<(List<Session>?, ApiException?)> getPatientSessions(
    String patientId, {
    bool? upcoming,
  });

  Future<(List<Assignment>?, ApiException?)> getPatientAssignments(
    String patientId, {
    bool? pending,
  });

  Future<(List<Advice>?, ApiException?)> getPatientAdvices(String patientId);

  Future<(Session?, ApiException?)> getSession(int id);

  Future<(Session?, ApiException?)> createSession(Session session);

  Future<(Session?, ApiException?)> updateSession(Session session);

  Future<(Assignment?, ApiException?)> createAssignment(Assignment assignment);

  Future<(Assignment?, ApiException?)> updateAssignment(Assignment assignment);

  Future<ApiException?> deleteAssignment(int id);

  Future<(Advice?, ApiException?)> createAdvice(Advice advice);

  Future<(Advice?, ApiException?)> updateAdvice(Advice advice);

  Future<ApiException?> deleteAdvice(int id);

  Future<(Schedule?, ApiException?)> createSchedule(Schedule schedule);

  Future<ApiException?> deleteSchedule(int id);
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final options = BaseOptions(baseUrl: dotenv.env['BASE_URL']!);
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggerInterceptor = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
  );
  final dio = Dio(options)..interceptors.addAll([authInterceptor, loggerInterceptor]);
  return ApiServiceImpl(dio);
});

class ApiServiceImpl implements ApiService {
  ApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiException?> sendVerificationCode(String phoneNumber) async {
    final (_, err) = await request(
      method: "POST",
      endpoint: "verification-code",
      requestBody: () => {
        "phoneNumber": phoneNumber,
      },
      parseSuccess: (response) {/* SUCCESS! */},
    );
    return err;
  }

  @override
  Future<(User?, ApiException?)> login(String phoneNumber, String code) async {
    return await request(
      method: "POST",
      endpoint: "login",
      requestBody: () => {
        "phoneNumber": phoneNumber,
        "code": code,
      },
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 406) {
          return const ApiUserNotRegisteredException();
        }
        return null;
      },
    );
  }

  @override
  Future<(User?, ApiException?)> signUp(String userName, UserRole role) async {
    return await request(
      method: "POST",
      endpoint: "signup",
      requestBody: () => {
        "name": userName,
        "role": role,
      },
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 406) {
          return const ApiUserAlreadyRegisteredException();
        }
        return null;
      },
    );
  }

  @override
  Future<(Invite?, ApiException?)> createInvite(String phoneNumber) async {
    return await request(
      method: "POST",
      endpoint: "invites",
      requestBody: () {
        return {"phone_number": phoneNumber};
      },
      parseSuccess: (response) {
        return Invite.fromJson(response.data);
      },
      parseFailure: (response) {
        switch (response.statusCode) {
          case 404:
            return const ApiPatientNotRegisteredException();
          case 409:
            final errorBody = json.decode(response.data) as Map<String, dynamic>;
            final errorCode = errorBody['code'] as String;
            switch (errorCode) {
              case "invite_already_sent":
                return const ApiInviteAlreadySentException();
              case "patient_already_with_doctor":
                return const ApiPatientAlreadyWithDoctorException();
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
  Future<(List<Invite>?, ApiException?)> getInvites() async {
    return await request(
      method: "GET",
      endpoint: "invites",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Invite.fromMap(e)).toList();
      },
      parseFailure: (response) {
        if (response.statusCode == 404) {
          return const ApiInvitesNotFoundException();
        }
        return null;
      },
    );
  }

  @override
  Future<ApiException?> deleteInvite(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "invites/$id",
      parseSuccess: (response) {/* SUCCESS! */},
    );
    return err;
  }

  @override
  Future<ApiException?> acceptInvite(int id) async {
    final (_, err) = await request(
      method: "POST",
      endpoint: "invites/$id/accept",
      parseSuccess: (response) {/* SUCCESS! */},
    );
    return err;
  }

  @override
  Future<(User?, ApiException?)> getUser(String uuid) async {
    return await request(
      method: "GET",
      endpoint: "users/$uuid",
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
    );
  }

  @override
  Future<(User?, ApiException?)> updateUser(User user) async {
    return await request(
      method: "PUT",
      endpoint: "users/${user.uuid}",
      requestBody: () {
        return user.toMap();
      },
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
    );
  }

  @override
  Future<(List<User>?, ApiException?)> getDoctorPatients(String doctorUuid) async {
    return await request(
      method: "GET",
      endpoint: "patients",
      buildQueryParameters: () => {
        "doctorUuid": doctorUuid,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => User.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Session>?, ApiException?)> getDoctorSessions(
    String doctorUuid, {
    DateTime? date,
  }) async {
    return await request(
      method: "GET",
      endpoint: "sessions",
      buildQueryParameters: () {
        if (date == null) return {"doctorUuid": doctorUuid};
        final formatter = DateFormat(AppConstants.datePattern);
        return {
          "date": formatter.format(date),
          "doctorUuid": doctorUuid,
        };
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Advice>?, ApiException?)> getDoctorAdvices(String doctorUuid) async {
    return await request(
      method: "GET",
      endpoint: "advices",
      buildQueryParameters: () => {
        "doctorUuid": doctorUuid,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Advice.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Schedule>?, ApiException?)> getDoctorSchedule(String doctorUuid) async {
    return await request(
      method: "GET",
      endpoint: "schedule",
      buildQueryParameters: () => {
        "doctorUuid": doctorUuid,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Schedule.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<User>?, ApiException?)> getPatientDoctors(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "doctors",
      buildQueryParameters: () => {
        "patientUuid": patientId,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => User.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Session>?, ApiException?)> getPatientSessions(
    String patientId, {
    bool? upcoming,
  }) async {
    return await request(
      method: "GET",
      endpoint: "sessions",
      buildQueryParameters: () => {
        "patientUuid": patientId,
        "upcoming": upcoming,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Assignment>?, ApiException?)> getPatientAssignments(
    String patientId, {
    bool? pending,
  }) async {
    return await request(
      method: "GET",
      endpoint: "assignments",
      buildQueryParameters: () => {
        "patientUuid": patientId,
        "pending": pending,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Assignment.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(List<Advice>?, ApiException?)> getPatientAdvices(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "advices",
      buildQueryParameters: () => {
        "patientUuid": patientId,
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Advice.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<(Session?, ApiException?)> getSession(int id) async {
    return await request(
      method: "GET",
      endpoint: "sessions/$id",
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
    );
  }

  @override
  Future<(Session?, ApiException?)> createSession(Session session) async {
    return await request(
      method: "POST",
      endpoint: "sessions",
      requestBody: () {
        return session.toMap();
      },
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 409) {
          return const ApiSessionAlreadyBookedException();
        }
        return null;
      },
    );
  }

  @override
  Future<(Session?, ApiException?)> updateSession(Session session) async {
    return await request(
      method: "PUT",
      endpoint: "sessions/${session.id}",
      requestBody: () {
        return session.toMap();
      },
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 409) {
          return const ApiSessionAlreadyBookedException();
        }
        return null;
      },
    );
  }

  @override
  Future<(Assignment?, ApiException?)> createAssignment(Assignment assignment) async {
    return await request(
      method: "POST",
      endpoint: "assignments",
      requestBody: () {
        return assignment.toMap();
      },
      parseSuccess: (response) {
        return Assignment.fromJson(response.data);
      },
    );
  }

  @override
  Future<(Assignment?, ApiException?)> updateAssignment(Assignment assignment) async {
    return await request(
      method: "PUT",
      endpoint: "assignments/${assignment.id}",
      requestBody: () {
        return assignment.toMap();
      },
      parseSuccess: (response) {
        return Assignment.fromJson(response.data);
      },
    );
  }

  @override
  Future<ApiException?> deleteAssignment(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "assignments/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
    return err;
  }

  @override
  Future<(Advice?, ApiException?)> createAdvice(Advice advice) async {
    return await request(
      method: "POST",
      endpoint: "advices",
      requestBody: () {
        return advice.toMap();
      },
      parseSuccess: (response) {
        return Advice.fromJson(response.data);
      },
    );
  }

  @override
  Future<(Advice?, ApiException?)> updateAdvice(Advice advice) async {
    return await request(
      method: "PUT",
      endpoint: "assignments/${advice.id}",
      requestBody: () {
        return advice.toMap();
      },
      parseSuccess: (response) {
        return Advice.fromJson(response.data);
      },
    );
  }

  @override
  Future<ApiException?> deleteAdvice(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "advices/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
    return err;
  }

  @override
  Future<(Schedule?, ApiException?)> createSchedule(Schedule schedule) async {
    return await request(
      method: "POST",
      endpoint: "schedule",
      requestBody: () {
        return schedule.toMap();
      },
      parseSuccess: (response) {
        return Schedule.fromJson(response.data);
      },
    );
  }

  @override
  Future<ApiException?> deleteSchedule(int id) async {
    final (_, err) = await request(
      method: "DELETE",
      endpoint: "schedule/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
    return err;
  }

  @visibleForTesting
  Future<(T?, ApiException?)> request<T>({
    required String method,
    required String endpoint,
    required T Function(Response response) parseSuccess,
    ApiException? Function(Response response)? parseFailure,
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

      switch (response.statusCode) {
        case 400:
          return (null, const ApiBadRequestException());
        case 401:
        case 403:
          return (null, const ApiUnauthorizedException());
      }

      if (response.statusCode == null ||
          !(response.statusCode! >= 200 && response.statusCode! < 300)) {
        final failure = parseFailure?.call(response);
        if (failure != null) {
          return (null, failure);
        }

        final nullData = response.data == null;
        final errorBody = nullData ? null : json.decode(response.data) as Map<dynamic, dynamic>;
        return (
          null,
          ApiException(
            message: nullData ? "Empty response data" : errorBody.toString(),
            code: "Status: ${response.statusCode}",
          ),
        );
      }

      return (parseSuccess(response), null);
    } on DioException catch (e) {
      if (e.error is ApiException) return (null, e.error as ApiException);
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        default:
          return (null, ApiConnectionException(message: e.message));
      }
    }
  }
}
