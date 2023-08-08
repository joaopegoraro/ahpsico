import 'dart:convert';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  Future<(Advice?, ApiError?)> updateAdvice(Advice advice);

  Future<ApiError?> deleteAdvice(int id);

  Future<(Schedule?, ApiError?)> createSchedule(Schedule schedule);

  Future<ApiError?> deleteSchedule(int id);
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
  Future<ApiError?> sendVerificationCode(String phoneNumber) async {
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
  Future<(User?, ApiError?)> login(String phoneNumber, String code) async {
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
      requestBody: () => {
        "name": userName,
        "role": role,
      },
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 406) {
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
      requestBody: () {
        return {"phone_number": phoneNumber};
      },
      parseSuccess: (response) {
        return Invite.fromJson(response.data);
      },
      parseFailure: (response) {
        switch (response.statusCode) {
          case 404:
            return const ApiPatientNotRegisteredError();
          case 409:
            final errorBody = json.decode(response.data) as Map<String, dynamic>;
            final errorCode = errorBody['code'] as String;
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
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Invite.fromMap(e)).toList();
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
        return User.fromJson(response.data);
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
        return User.fromJson(response.data);
      },
    );
  }

  @override
  Future<(List<User>?, ApiError?)> getDoctorPatients(String doctorUuid) async {
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
  Future<(List<Session>?, ApiError?)> getDoctorSessions(
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
  Future<(List<Advice>?, ApiError?)> getDoctorAdvices(String doctorUuid) async {
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
  Future<(List<Schedule>?, ApiError?)> getDoctorSchedule(String doctorUuid) async {
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
  Future<(List<User>?, ApiError?)> getPatientDoctors(String patientId) async {
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
  Future<(List<Session>?, ApiError?)> getPatientSessions(
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
  Future<(List<Assignment>?, ApiError?)> getPatientAssignments(
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
  Future<(List<Advice>?, ApiError?)> getPatientAdvices(String patientId) async {
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
  Future<(Session?, ApiError?)> getSession(int id) async {
    return await request(
      method: "GET",
      endpoint: "sessions/$id",
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
    );
  }

  @override
  Future<(Session?, ApiError?)> createSession(Session session) async {
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
      requestBody: () {
        return session.toMap();
      },
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 409) {
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
      requestBody: () {
        return assignment.toMap();
      },
      parseSuccess: (response) {
        return Assignment.fromJson(response.data);
      },
    );
  }

  @override
  Future<(Assignment?, ApiError?)> updateAssignment(Assignment assignment) async {
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
      requestBody: () {
        return advice.toMap();
      },
      parseSuccess: (response) {
        return Advice.fromJson(response.data);
      },
    );
  }

  @override
  Future<(Advice?, ApiError?)> updateAdvice(Advice advice) async {
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
        return Schedule.fromJson(response.data);
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
    ApiError? Function(Response response)? parseFailure,
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
          return (null, const ApiBadRequestError());
        case 401:
        case 403:
          return (null, const ApiUnauthorizedError());
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
          ApiError(
            message: nullData ? "Empty response data" : errorBody.toString(),
            code: "Status: ${response.statusCode}",
          ),
        );
      }

      return (parseSuccess(response), null);
    } on DioException catch (e) {
      if (e.error is ApiError) return (null, e.error as ApiError);
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        default:
          return (null, ApiConnectionError(message: e.message));
      }
    }
  }
}
