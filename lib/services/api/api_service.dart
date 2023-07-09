import 'dart:convert';

import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/auth_interceptor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<User> signUp();

  /// throws:
  /// - [ApiPatientNotRegisteredException] when there is not patient registered
  /// with the phone number that was passed;
  /// - [ApiPatientAlreadyWithDoctorException] when the patient you are trying to
  /// invite already is your patient;
  Future<void> createInvite(String phoneNumber);

  /// Returns the queried invite
  Future<Invite> getInvite(int id);

  Future<void> deleteInvite(int id);

  Future<void> acceptInvite(int id);

  Future<Doctor> getDoctor(String uuid);

  Future<Doctor> updateDoctor(Doctor doctor);

  Future<List<Patient>> getDoctorPatients(String uuid);
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

  /// throws [ApiUserAlreadyRegisteredException] when the user trying to sign up is
  /// already registered.

  /// Returns the user data
  @override
  Future<User> signUp() async {
    return await _request(
      method: "POST",
      endpoint: "signup",
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

  /// throws:
  /// - [ApiPatientNotRegisteredException] when there is not patient registered
  /// with the phone number that was passed;
  /// - [ApiPatientAlreadyWithDoctorException] when the patient you are trying to
  /// invite already is your patient;
  ///
  /// Returns the created invite
  @override
  Future<Invite> createInvite(String phoneNumber) async {
    return await _request(
      method: "POST",
      endpoint: "invites",
      requestBody: () {
        return {"phone_number": phoneNumber};
      },
      parseSuccess: (response) {
        return Invite.fromJson(response.data);
      },
      parseFailure: (response) {
        if (response.statusCode == 404) {
          final errorBody = json.decode(response.data) as Map<String, dynamic>;
          final errorCode = errorBody['code'] as String;
          switch (errorCode) {
            case "patient_not_registered":
              throw const ApiPatientNotRegisteredException();
            case "patient_already_with_doctor":
              throw const ApiPatientAlreadyWithDoctorException();
          }
        }
      },
    );
  }

  /// Returns the queried invite
  @override
  Future<Invite> getInvite(int id) async {
    return await _request(
      method: "GET",
      endpoint: "invites/$id",
      parseSuccess: (response) {
        return Invite.fromJson(response.data);
      },
    );
  }

  @override
  Future<void> deleteInvite(int id) async {
    return await _request(
      method: "DELETE",
      endpoint: "invites/$id",
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<void> acceptInvite(int id) async {
    return await _request(
      method: "POST",
      endpoint: "invites/$id/accept",
      parseSuccess: (response) {/* SUCCESS! */},
    );
  }

  @override
  Future<Doctor> getDoctor(String uuid) async {
    return await _request(
      method: "GET",
      endpoint: "doctors/$uuid",
      parseSuccess: (response) {
        return Doctor.fromJson(response.data);
      },
    );
  }

  @override
  Future<Doctor> updateDoctor(Doctor doctor) async {
    return await _request(
      method: "PUT",
      endpoint: "doctors",
      requestBody: () {
        return doctor.toMap();
      },
      parseSuccess: (response) {
        return Doctor.fromJson(response.data);
      },
    );
  }

  @override
  Future<List<Patient>> getDoctorPatients(String uuid) async {
    return await _request(
      method: "GET",
      endpoint: "doctors/$uuid/patients",
      parseSuccess: (response) {
        final List jsonList = json.decode(response.data);
        return jsonList.map((e) => Patient.fromMap(e)).toList();
      },
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
  Future<T> _request<T>({
    required String method,
    required String endpoint,
    required T Function(Response response) parseSuccess,
    Never? Function(Response response)? parseFailure,
    Object Function()? requestBody,
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

      if (response.statusCode == null || (response.statusCode! >= 200 && response.statusCode! < 300)) {
        parseFailure?.call(response);
        final errorBody = json.decode(response.data) as Map<String, dynamic>;
        throw ApiException(message: errorBody.toString());
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
          // ApiException(message: e.message).throwWithStackTrace(stackTrace);
          rethrow;
      }
    } on JsonUnsupportedObjectError catch (e, stackTrace) {
      const ApiEncodeRequestException().throwWithStackTrace(stackTrace);
    } on FormatException catch (e, stackTrace) {
      ApiDecodeResponseException(message: e.message).throwWithStackTrace(stackTrace);
    }
  }
}
