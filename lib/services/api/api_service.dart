import 'dart:convert';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract interface class ApiService {
  /// throws:
  /// - [ApiUserNotRegisteredException] when the user trying to login is
  /// not yet registered.
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// The login credential is the [AuthToken] that is passed
  /// in the headers.

  /// Returns the user data
  Future<User> login();

  /// throws:
  /// - [ApiUserAlreadyRegisteredException] when the user trying to sign up is
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  /// already registered.

  /// Returns the user data
  Future<User> signUp(User user);

  /// throws:
  /// - [ApiPatientNotRegisteredException] when there is not patient registered
  /// with the phone number that was passed;
  /// - [ApiPatientAlreadyWithDoctorException] when the patient you are trying to
  /// invite already is your patient;
  /// - [ApiInviteAlreadySentException] when this invite was already sent to the patient;
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - The created [Invite]
  Future<Invite> createInvite(String phoneNumber);

  /// throws:
  /// - [ApiInvitesNotFoundException] when there are no invites tied to this account
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Invite>> getInvites();

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> deleteInvite(int id);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> acceptInvite(int id);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Doctor> getDoctor(String uuid);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Doctor> updateDoctor(Doctor doctor);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Patient>> getDoctorPatients(String doctorId);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Session>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Advice>> getDoctorAdvices(String doctorId);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Patient> getPatient(String uuid);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Patient> updatePatient(Patient patient);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Doctor>> getPatientDoctors(String patientId);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Session>> getPatientSessions(
    String patientId, {
    bool? upcoming,
  });

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Assignment>> getPatientAssignments(
    String patientId, {
    bool? pending,
  });

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<List<Advice>> getPatientAdvices(String patientId);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Session> getSession(int id);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Session> createSession(Session session);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Session> updateSession(Session session);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Assignment> createAssignment(Assignment assignment);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Assignment> updateAssignment(Assignment assignment);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> deleteAssignment(int id);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Advice> createAdvice(Advice advice);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<Advice> updateAdvice(Advice advice);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> deleteAdvice(int id);
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
  Future<User> login() async {
    return await request(
      method: "POST",
      endpoint: "login",
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 406) {
          throw const ApiUserNotRegisteredException();
        }
      },
    );
  }

  @override
  Future<User> signUp(User user) async {
    return await request(
      method: "POST",
      endpoint: "signup",
      requestBody: () {
        return user.toMap();
      },
      parseSuccess: (response) {
        return User.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 406) {
          throw const ApiUserAlreadyRegisteredException();
        }
      },
    );
  }

  @override
  Future<Invite> createInvite(String phoneNumber) async {
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
            throw const ApiPatientNotRegisteredException();
          case 409:
            final errorBody = json.decode(response.data) as Map<String, dynamic>;
            final errorCode = errorBody['code'] as String;
            switch (errorCode) {
              case "invite_already_sent":
                throw const ApiInviteAlreadySentException();
              case "patient_already_with_doctor":
                throw const ApiPatientAlreadyWithDoctorException();
            }
        }
      },
    );
  }

  @override
  Future<List<Invite>> getInvites() async {
    return await request(
      method: "GET",
      endpoint: "invites",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Invite.fromMap(e)).toList();
      },
      parseFailure: (response) {
        if (response.statusCode == 404) {
          throw const ApiInvitesNotFoundException();
        }
      },
    );
  }

  @override
  Future<void> deleteInvite(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "invites/$id",
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<void> acceptInvite(int id) async {
    return await request(
      method: "POST",
      endpoint: "invites/$id/accept",
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<Doctor> getDoctor(String uuid) async {
    return await request(
      method: "GET",
      endpoint: "doctors/$uuid",
      parseSuccess: (response) {
        return Doctor.fromJson(response.data);
      },
    );
  }

  @override
  Future<Doctor> updateDoctor(Doctor doctor) async {
    return await request(
      method: "PUT",
      endpoint: "doctors/${doctor.uuid}",
      requestBody: () {
        return doctor.toMap();
      },
      parseSuccess: (response) {
        return Doctor.fromJson(response.data);
      },
    );
  }

  @override
  Future<List<Patient>> getDoctorPatients(String doctorId) async {
    return await request(
      method: "GET",
      endpoint: "doctors/$doctorId/patients",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Patient.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<List<Session>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  }) async {
    return await request(
      method: "GET",
      endpoint: "doctors/$doctorId/sessions",
      buildQueryParameters: () {
        if (date == null) return null;
        final formatter = DateFormat(AppConstants.datePattern);
        return {"date": formatter.format(date)};
      },
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<List<Advice>> getDoctorAdvices(String doctorId) async {
    return await request(
      method: "GET",
      endpoint: "doctors/$doctorId/advices",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Advice.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<Patient> getPatient(String uuid) async {
    return await request(
      method: "GET",
      endpoint: "patients/$uuid",
      parseSuccess: (response) {
        return Patient.fromJson(response.data);
      },
    );
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    return await request(
      method: "PUT",
      endpoint: "patients/${patient.uuid}",
      requestBody: () {
        return patient.toMap();
      },
      parseSuccess: (response) {
        return Patient.fromJson(response.data);
      },
    );
  }

  @override
  Future<List<Doctor>> getPatientDoctors(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "patients/$patientId/doctors",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Doctor.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<List<Session>> getPatientSessions(
    String patientId, {
    bool? upcoming,
  }) async {
    return await request(
      method: "GET",
      endpoint: "patients/$patientId/sessions",
      buildQueryParameters: upcoming != true ? null : () => {"upcoming": upcoming},
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<List<Assignment>> getPatientAssignments(
    String patientId, {
    bool? pending,
  }) async {
    return await request(
      method: "GET",
      endpoint: "patients/$patientId/assignments",
      buildQueryParameters: pending != true ? null : () => {"pending": pending},
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Assignment.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<List<Advice>> getPatientAdvices(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "patients/$patientId/advices",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Advice.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<Session> getSession(int id) async {
    return await request(
      method: "GET",
      endpoint: "sessions/$id",
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
    );
  }

  @override
  Future<Session> createSession(Session session) async {
    return await request(
      method: "POST",
      endpoint: "sessions",
      requestBody: () {
        return session.toMap();
      },
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
    );
  }

  @override
  Future<Session> updateSession(Session session) async {
    return await request(
      method: "PUT",
      endpoint: "sessions/${session.id}",
      requestBody: () {
        return session.toMap();
      },
      parseSuccess: (response) {
        return Session.fromJson(response.data);
      },
    );
  }

  @override
  Future<Assignment> createAssignment(Assignment assignment) async {
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
  Future<Assignment> updateAssignment(Assignment assignment) async {
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
  Future<void> deleteAssignment(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "assignments/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
  }

  @override
  Future<Advice> createAdvice(Advice advice) async {
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
  Future<Advice> updateAdvice(Advice advice) async {
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
  Future<void> deleteAdvice(int id) async {
    return await request(
      method: "DELETE",
      endpoint: "advices/$id",
      parseSuccess: (response) {/* SUCCESS */},
    );
  }

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  @visibleForTesting
  Future<T> request<T>({
    required String method,
    required String endpoint,
    required T Function(Response response) parseSuccess,
    Never? Function(Response response)? parseFailure,
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
        case 401:
        case 403:
          throw const ApiUnauthorizedException();
      }

      if (response.statusCode == null || !(response.statusCode! >= 200 && response.statusCode! < 300)) {
        parseFailure?.call(response);
        final nullData = response.data == null;
        final errorBody = nullData ? null : json.decode(response.data) as Map<dynamic, dynamic>;
        throw ApiException(
          message: nullData ? "Empty response data" : errorBody.toString(),
          code: "Status: ${response.statusCode}",
        );
      }

      return parseSuccess(response);
    } on DioException catch (e, stackTrace) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          ApiConnectionException(message: e.message).throwWithStackTrace(stackTrace);
        default:
          ApiException(message: e.message).throwWithStackTrace(stackTrace);
      }
    }
  }
}
