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
import 'package:ahpsico/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract interface class ApiService {
  Future<Result<void, ApiException>> sendVerificationCode(String phoneNumber);

  Future<Result<User, ApiException>> login(String phoneNumber, String code);

  Future<Result<User, ApiException>> signUp(String userName, UserRole role);

  Future<Result<Invite, ApiException>> createInvite(String phoneNumber);

  Future<Result<List<Invite>, ApiException>> getInvites();

  Future<Result<void, ApiException>> deleteInvite(int id);

  Future<Result<void, ApiException>> acceptInvite(int id);

  Future<Result<User, ApiException>> getUser(String uuid);

  Future<Result<User, ApiException>> updateUser(User user);

  Future<Result<List<User>, ApiException>> getDoctorPatients(String doctorId);

  Future<Result<List<Session>, ApiException>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  Future<Result<List<Advice>, ApiException>> getDoctorAdvices(String doctorId);

  Future<Result<List<Schedule>, ApiException>> getDoctorSchedule(String doctorId);

  Future<Result<List<User>, ApiException>> getPatientDoctors(String patientId);

  Future<Result<List<Session>, ApiException>> getPatientSessions(
    String patientId, {
    bool? upcoming,
  });

  Future<Result<List<Assignment>, ApiException>> getPatientAssignments(
    String patientId, {
    bool? pending,
  });

  Future<Result<List<Advice>, ApiException>> getPatientAdvices(String patientId);

  Future<Result<Session, ApiException>> getSession(int id);

  Future<Result<Session, ApiException>> createSession(Session session);

  Future<Result<Session, ApiException>> updateSession(Session session);

  Future<Result<Assignment, ApiException>> createAssignment(Assignment assignment);

  Future<Result<Assignment, ApiException>> updateAssignment(Assignment assignment);

  Future<Result<void, ApiException>> deleteAssignment(int id);

  Future<Result<Advice, ApiException>> createAdvice(Advice advice);

  Future<Result<Advice, ApiException>> updateAdvice(Advice advice);

  Future<Result<void, ApiException>> deleteAdvice(int id);

  Future<Result<Schedule, ApiException>> createSchedule(Schedule schedule);

  Future<Result<void, ApiException>> deleteSchedule(int id);
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
  Future<Result<void, ApiException>> sendVerificationCode(String phoneNumber) async {
    return await request(
      method: "POST",
      endpoint: "verification-code",
      requestBody: () => {
        "phoneNumber": phoneNumber,
      },
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<Result<User, ApiException>> login(String phoneNumber, String code) async {
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
          return const Failure(ApiUserNotRegisteredException());
        }
        return null;
      },
    );
  }

  @override
  Future<Result<User, ApiException>> signUp(String userName, UserRole role) async {
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
          return const Failure(ApiUserAlreadyRegisteredException());
        }
        return null;
      },
    );
  }

  @override
  Future<Result<Invite, ApiException>> createInvite(String phoneNumber) async {
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
            return const Failure(ApiPatientNotRegisteredException());
          case 409:
            final errorBody = json.decode(response.data) as Map<String, dynamic>;
            final errorCode = errorBody['code'] as String;
            switch (errorCode) {
              case "invite_already_sent":
                return const Failure(ApiInviteAlreadySentException());
              case "patient_already_with_doctor":
                return const Failure(ApiPatientAlreadyWithDoctorException());
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
  Future<Result<List<Invite>, ApiException>> getInvites() async {
    return await request(
      method: "GET",
      endpoint: "invites",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Invite.fromMap(e)).toList();
      },
      parseFailure: (response) {
        if (response.statusCode == 404) {
          return const Failure(ApiInvitesNotFoundException());
        }
        return null;
      },
    );
  }

  @override
  Future<Result<void, ApiException>> deleteInvite(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "invites/$id",
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<Result<void, ApiException>> acceptInvite(int id) async {
    return await request(
      method: "POST",
      endpoint: "invites/$id/accept",
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<Result<User, ApiException>> getUser(String uuid) async {
    return await request(
      method: "GET",
      endpoint: "users/$uuid",
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
    );
  }

  @override
  Future<Result<User, ApiException>> updateUser(User user) async {
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
  Future<Result<List<User>, ApiException>> getDoctorPatients(String doctorUuid) async {
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
  Future<Result<List<Session>, ApiException>> getDoctorSessions(
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
  Future<Result<List<Advice>, ApiException>> getDoctorAdvices(String doctorUuid) async {
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
  Future<Result<List<Schedule>, ApiException>> getDoctorSchedule(String doctorUuid) async {
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
  Future<Result<List<User>, ApiException>> getPatientDoctors(String patientId) async {
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
  Future<Result<List<Session>, ApiException>> getPatientSessions(
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
  Future<Result<List<Assignment>, ApiException>> getPatientAssignments(
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
  Future<Result<List<Advice>, ApiException>> getPatientAdvices(String patientId) async {
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
  Future<Result<Session, ApiException>> getSession(int id) async {
    return await request(
      method: "GET",
      endpoint: "sessions/$id",
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
    );
  }

  @override
  Future<Result<Session, ApiException>> createSession(Session session) async {
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
          return const Failure(ApiSessionAlreadyBookedException());
        }
        return null;
      },
    );
  }

  @override
  Future<Result<Session, ApiException>> updateSession(Session session) async {
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
          return const Failure(ApiSessionAlreadyBookedException());
        }
        return null;
      },
    );
  }

  @override
  Future<Result<Assignment, ApiException>> createAssignment(Assignment assignment) async {
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
  Future<Result<Assignment, ApiException>> updateAssignment(Assignment assignment) async {
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
  Future<Result<void, ApiException>> deleteAssignment(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "assignments/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
  }

  @override
  Future<Result<Advice, ApiException>> createAdvice(Advice advice) async {
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
  Future<Result<Advice, ApiException>> updateAdvice(Advice advice) async {
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
  Future<Result<void, ApiException>> deleteAdvice(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "advices/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
  }

  @override
  Future<Result<Schedule, ApiException>> createSchedule(Schedule schedule) async {
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
  Future<Result<void, ApiException>> deleteSchedule(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "schedule/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
  }

  @visibleForTesting
  Future<Result<T, ApiException>> request<T>({
    required String method,
    required String endpoint,
    required T Function(Response response) parseSuccess,
    Failure<T, ApiException>? Function(Response response)? parseFailure,
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
          return const Failure(ApiBadRequestException());
        case 401:
        case 403:
          return const Failure(ApiUnauthorizedException());
      }

      if (response.statusCode == null ||
          !(response.statusCode! >= 200 && response.statusCode! < 300)) {
        final failure = parseFailure?.call(response);
        if (failure != null) {
          return failure;
        }

        final nullData = response.data == null;
        final errorBody = nullData ? null : json.decode(response.data) as Map<dynamic, dynamic>;
        return Failure(
          ApiException(
            message: nullData ? "Empty response data" : errorBody.toString(),
            code: "Status: ${response.statusCode}",
          ),
        );
      }

      return Success(parseSuccess(response));
    } on DioException catch (e) {
      if (e.error is ApiException) return Failure(e.error as ApiException);
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        default:
          return Failure(ApiConnectionException(message: e.message));
      }
    }
  }
}
