import 'dart:convert';

import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  final mockDio = MockDio();
  final ApiService apiService = ApiServiceImpl(mockDio);
  final ApiServiceImpl apiServiceImpl = apiService as ApiServiceImpl;

  const mockedUser = User(
    uid: "some uid",
    name: "some name",
    phoneNumber: "some number",
    isDoctor: true,
  );

  final mockedDoctor = Doctor(
    uuid: mockedUser.uid,
    name: mockedUser.name,
    phoneNumber: mockedUser.phoneNumber,
    description: "some description",
    crp: "some crp",
    pixKey: "some pix key",
    paymentDetails: "some payment details",
  );

  final mockedPatient = Patient(
    uuid: mockedUser.uid,
    name: mockedUser.name,
    phoneNumber: mockedUser.phoneNumber,
  );

  final mockedInvite = Invite(
    id: 1,
    doctor: mockedDoctor,
    patientId: mockedPatient.uuid,
    phoneNumber: mockedUser.phoneNumber,
  );

  final mockedSession = Session(
    id: 1,
    doctor: mockedDoctor,
    patient: mockedPatient,
    groupId: 1,
    groupIndex: 1,
    status: SessionStatus.canceled,
    type: SessionType.individual,
    date: "some date",
  );

  final mockedAdvice = Advice(
    id: 1,
    message: "some message",
    doctor: mockedDoctor,
    patientIds: List.generate(10, (index) => index.toString()),
  );

  Future<void> testRequest<T>({
    bool onlyMock = false,
    String method = "GET",
    String endpoint = "some_endpoint",
    int statusCode = 200,
    String? responseBody,
    Object? Function()? requestBody,
    T Function(Response response)? parseSuccess,
    Never? Function(Response response)? parseFailure,
    Never? Function()? throwResponse,
  }) async {
    when(
      () => mockDio.request(
        any(),
        data: any(named: "data"),
        queryParameters: any(named: "queryParameters"),
        options: any(named: "options"),
      ),
    ).thenAnswer((_) async {
      throwResponse?.call();
      return Response(
        data: responseBody,
        statusCode: statusCode,
        requestOptions: RequestOptions(),
      );
    });
    if (!onlyMock) {
      await apiServiceImpl.request<T?>(
        method: method,
        endpoint: endpoint,
        requestBody: requestBody,
        parseFailure: parseFailure,
        parseSuccess: (response) {
          return parseSuccess?.call(response);
        },
      );
    }
  }

  group("request", () {
    test("Response with error code should throw ApiException if no parseFailure has been provided", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      final decodedBody = json.decode(bodyJson) as Map<String, dynamic>;
      try {
        await testRequest(
          responseBody: bodyJson,
          statusCode: 404,
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
      try {
        await testRequest(statusCode: 404);
        assert(false);
      } on ApiException catch (e) {
        assert(e.message != null);
        assert(e.code == null);
      }
    });

    test("Response with status 400 throws ApiBadRequestException", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      final decodedBody = json.decode(bodyJson) as Map<String, dynamic>;
      try {
        await testRequest(
          responseBody: bodyJson,
          statusCode: 400,
        );
        assert(false);
      } on ApiBadRequestException catch (e) {
        final expectedException = ApiBadRequestException(message: decodedBody.toString());
        assert(e.message == expectedException.message);
      }
    });

    test("Response with status 401 throws ApiUnauthorizedException", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      try {
        await testRequest(
          responseBody: bodyJson,
          statusCode: 401,
        );
        assert(false);
      } on ApiUnauthorizedException catch (_) {
        assert(true);
      }
    });

    test("Response with status 403 throws ApiUnauthorizedException", () async {
      final bodyJson = json.encode({'mensagem': 'erro'});
      try {
        await testRequest(
          responseBody: bodyJson,
          statusCode: 403,
        );
        assert(false);
      } on ApiUnauthorizedException catch (_) {
        assert(true);
      }
    });

    test("Response with connection timeout throws ApiTimeoutException", () async {
      const message = "timeout";
      try {
        await testRequest(
          throwResponse: () => throw DioException(
            message: message,
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        assert(false);
      } on ApiTimeoutException catch (e) {
        const expectedException = ApiTimeoutException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with send timeout throws ApiTimeoutException", () async {
      const message = "timeout";
      try {
        await testRequest(
          throwResponse: () => throw DioException(
            message: message,
            requestOptions: RequestOptions(),
            type: DioExceptionType.sendTimeout,
          ),
        );
        assert(false);
      } on ApiTimeoutException catch (e) {
        const expectedException = ApiTimeoutException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with receive timeout throws ApiTimeoutException", () async {
      const message = "timeout";
      try {
        await testRequest(
          throwResponse: () => throw DioException(
            message: message,
            requestOptions: RequestOptions(),
            type: DioExceptionType.receiveTimeout,
          ),
        );
        assert(false);
      } on ApiTimeoutException catch (e) {
        const expectedException = ApiTimeoutException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with connection error throws ApiConnectionException", () async {
      const message = "timeout";
      try {
        await testRequest(
          throwResponse: () => throw DioException(
            message: message,
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );
        assert(false);
      } on ApiConnectionException catch (e) {
        const expectedException = ApiConnectionException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Response with unknown dio exception throws ApiException", () async {
      const message = "timeout";
      try {
        await testRequest(
          throwResponse: () => throw DioException(
            message: message,
            requestOptions: RequestOptions(),
          ),
        );
        assert(false);
      } on ApiException catch (e) {
        const expectedException = ApiException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Error encoding request throws ApiEncodeRequestException", () async {
      try {
        await testRequest(requestBody: () => throw JsonUnsupportedObjectError(null));
        assert(false);
      } on ApiEncodeRequestException catch (_) {
        assert(true);
      }
    });

    test("Error decoding response throws ApiDecodeResponseException", () async {
      const message = "timeout";
      try {
        await testRequest(parseSuccess: (_) => throw const FormatException(message));
        assert(false);
      } on ApiDecodeResponseException catch (e) {
        const expectedException = ApiDecodeResponseException(message: message);
        assert(e.message == expectedException.message);
      }
    });

    test("Error typing decoded response throws ApiDecodeResponseException", () async {
      try {
        await testRequest(parseSuccess: (_) => throw TypeError());
        assert(false);
      } on ApiDecodeResponseException catch (_) {
        assert(true);
      }
    });
  });

  group("login", () {
    test("response with status code 406 throws ApiUserNotRegisteredException", () async {
      try {
        await testRequest(onlyMock: true, statusCode: 406);
        await apiService.login();
        assert(false);
      } on ApiUserNotRegisteredException catch (_) {
        assert(true);
      }
    });

    test("successful response returns User", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedUser.toJson(),
      );
      final user = await apiService.login();
      assert(user == mockedUser);
    });
  });

  group("sign up", () {
    test("response with status code 406 throws ApiAlreadyRegisteredException", () async {
      try {
        await testRequest(onlyMock: true, statusCode: 406);
        await apiService.signUp(mockedUser);
        assert(false);
      } on ApiUserAlreadyRegisteredException catch (_) {
        assert(true);
      }
    });

    test("successful response returns User", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedUser.toJson(),
      );
      final user = await apiService.signUp(mockedUser);
      assert(user == mockedUser);
    });
  });

  group("invites", () {
    group("create invite", () {
      test("response with code patient_not_registered throws ApiPatientNotRegisteredException", () async {
        const body = {'code': "patient_not_registered"};
        try {
          await testRequest(
            onlyMock: true,
            statusCode: 404,
            responseBody: json.encode(body),
          );
          await apiService.createInvite(mockedInvite.phoneNumber);
          assert(false);
        } on ApiPatientNotRegisteredException catch (_) {
          assert(true);
        }
      });

      test("response with code patient_already_with_doctor throws ApiPatientNotRegisteredException", () async {
        const body = {'code': "patient_already_with_doctor"};
        try {
          await testRequest(
            onlyMock: true,
            statusCode: 404,
            responseBody: json.encode(body),
          );
          await apiService.createInvite(mockedInvite.phoneNumber);
          assert(false);
        } on ApiPatientAlreadyWithDoctorException catch (_) {
          assert(true);
        }
      });

      test("successful response returns invite", () async {
        await testRequest(
          onlyMock: true,
          responseBody: mockedInvite.toJson(),
        );
        final invite = await apiService.createInvite(mockedInvite.phoneNumber);
        assert(invite == mockedInvite);
      });
    });

    test("successfully creating invite returns invite", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedInvite.toJson(),
      );
      final invite = await apiService.getInvite(mockedInvite.id);
      assert(invite == mockedInvite);
    });

    test("successfully deleting invite doesn't throw", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedInvite.toJson(),
      );
      await apiService.deleteAdvice(mockedInvite.id);
    });

    test("successfully accepting invite doesn't throw", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedInvite.toJson(),
      );
      await apiService.acceptInvite(mockedInvite.id);
    });
  });

  group("doctors", () {
    test("successfully retrieving doctor returns doctor", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedDoctor.toJson(),
      );
      final doctor = await apiService.getDoctor(mockedDoctor.uuid);
      assert(doctor == mockedDoctor);
    });

    test("successfully updating doctor returns doctor", () async {
      await testRequest(
        onlyMock: true,
        responseBody: mockedDoctor.toJson(),
      );
      final doctor = await apiService.updateDoctor(mockedDoctor);
      assert(doctor == mockedDoctor);
    });

    test("successfully retrieving doctor patients returns patient list", () async {
      final expectedPatients = List.generate(1, (index) => mockedPatient.copyWith(uuid: "some other id $index"));
      await testRequest(
        onlyMock: true,
        responseBody: json.encode(expectedPatients.map((patient) => patient.toMap()).toList()),
      );
      final patients = await apiService.getDoctorPatients(mockedDoctor.uuid);
      assert(const ListEquality().equals(patients, expectedPatients));
    });

    test("successfully retrieving doctor sessions returns session list", () async {
      final expectedSessions = List.generate(1, (index) => mockedSession.copyWith(id: index));
      await testRequest(
        onlyMock: true,
        responseBody: json.encode(expectedSessions.map((e) => e.toMap()).toList()),
      );
      final sessions = await apiService.getDoctorSessions(mockedDoctor.uuid);
      assert(const ListEquality().equals(sessions, expectedSessions));
    });

    test("successfully retrieving doctor advices returns advice list", () async {
      final expectedAdvice = List.generate(1, (index) => mockedAdvice.copyWith(id: index));
      await testRequest(
        onlyMock: true,
        responseBody: json.encode(expectedAdvice.map((e) => e.toMap()).toList()),
      );
      final advices = await apiService.getDoctorAdvices(mockedDoctor.uuid);
      assert(const ListEquality().equals(advices, expectedAdvice));
    });
  });
}
