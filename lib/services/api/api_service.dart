import 'dart:convert';

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
import 'package:meta/meta.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// All service methods can throw [ApiException] :
/// - base [ApiException] when the response returns with an error status;
/// - [ApiTimeoutException] when the request times out;
/// - [ApiConnectionException] when the request suffers any connection problems;
/// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
/// - [ApiBadRequestException] when the response returns a status of 400;
/// - [ApiEncodeRequestException] when there is a problem in encoding the request body;
/// - [ApiDecodeResponseException] when there is a problem in decoding the response body;
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
  Future<User> signUp(User user);

  /// throws:
  /// - [ApiPatientNotRegisteredException] when there is not patient registered
  /// with the phone number that was passed;
  /// - [ApiPatientAlreadyWithDoctorException] when the patient you are trying to
  /// invite already is your patient;
  /// - [ApiInviteAlreadySentException] when this invite was already sent to the patient;
  Future<void> createInvite(String phoneNumber);

  /// throws:
  /// - [ApiInvitesNotFoundException] when there are no invites tied to this account
  Future<List<Invite>> getInvites();

  Future<void> deleteInvite(int id);

  Future<void> acceptInvite(int id);

  Future<Doctor> getDoctor(String uuid);

  Future<Doctor> updateDoctor(Doctor doctor);

  Future<List<Patient>> getDoctorPatients(String doctorId);

  Future<List<Session>> getDoctorSessions(String doctorId);

  Future<List<Advice>> getDoctorAdvices(String doctorId);

  Future<Patient> getPatient(String uuid);

  Future<Patient> updatePatient(Patient patient);

  Future<List<Doctor>> getPatientDoctors(String patientId);

  Future<List<Session>> getPatientSessions(String patientId);

  Future<List<Assignment>> getPatientAssignments(String patientId);

  Future<List<Advice>> getPatientAdvices(String patientId);

  Future<Session> getSession(int id);

  Future<Session> createSession(Session session);

  Future<Session> updateSession(Session session);

  Future<Assignment> getAssignment(int id);

  Future<Assignment> createAssignment(Assignment assignment);

  Future<Assignment> updateAssignment(Assignment assignment);

  Future<void> deleteAssignment(int id);

  Future<Advice> getAdvice(int id);

  Future<Advice> createAdvice(Advice advice);

  Future<Advice> updateAdvice(Advice advice);

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
  Future<List<Session>> getDoctorSessions(String doctorId) async {
    return await request(
      method: "GET",
      endpoint: "doctors/$doctorId/sessions",
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
  Future<List<Session>> getPatientSessions(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "patients/$patientId/sessions",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Session.fromMap(e)).toList();
      },
    );
  }

  @override
  Future<List<Assignment>> getPatientAssignments(String patientId) async {
    return await request(
      method: "GET",
      endpoint: "patients/$patientId/assignments",
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
  Future<Assignment> getAssignment(int id) async {
    return await request(
      method: "GET",
      endpoint: "assignments/$id",
      parseSuccess: (response) {
        return Assignment.fromJson(response.data);
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
  Future<Advice> getAdvice(int id) async {
    return await request(
      method: "GET",
      endpoint: "advices/$id",
      parseSuccess: (response) {
        return Advice.fromJson(response.data);
      },
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

  /// throws [ApiException] :
  /// - base [ApiException] when the response returns with an error status;
  /// - [ApiTimeoutException] when the request times out;
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  /// - [ApiBadRequestException] when the response returns a status of 400;
  /// - [ApiEncodeRequestException] when there is a problem in encoding the request body;
  /// - [ApiDecodeResponseException] when there is a problem in decoding the response body;
  @visibleForTesting
  Future<T> request<T>({
    required String method,
    required String endpoint,
    required T Function(Response response) parseSuccess,
    Never? Function(Response response)? parseFailure,
    Object? Function()? requestBody,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: requestBody?.call(),
        queryParameters: queryParameters,
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

      if (response.statusCode == null || !(response.statusCode! >= 200 && response.statusCode! < 300)) {
        try {
          parseFailure?.call(response);
          final errorBody = json.decode(response.data) as Map<String, dynamic>;
          throw ApiException(message: errorBody.toString());
        } on FormatException catch (e, stackTrace) {
          ApiException(message: e.message).throwWithStackTrace(stackTrace);
        } on TypeError catch (e, stackTrace) {
          ApiException(message: e.toString()).throwWithStackTrace(stackTrace);
        }
      }

      return parseSuccess(response);
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
    } on TypeError catch (e, stackTrace) {
      ApiDecodeResponseException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }
}
