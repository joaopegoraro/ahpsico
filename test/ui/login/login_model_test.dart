import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/services/auth/auth_user.dart';
import 'package:ahpsico/services/auth/credentials.dart';
import 'package:ahpsico/services/auth/exceptions.dart';
import 'package:ahpsico/services/auth/token.dart';
import 'package:ahpsico/ui/login/login_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  final mockAuthService = MockAuthService();
  final mockUserRepository = MockUserRepository();

  LoginModel? loginModel;

  const token = AuthToken("some token");
  final user = User(
    uid: faker.guid.guid(),
    name: faker.person.name(),
    phoneNumber: faker.phoneNumber.random.fromPattern([LoginModel.phoneMaskPattern]),
    isDoctor: false,
  );

  setUp(() {
    loginModel = LoginModel(mockUserRepository, mockAuthService);
  });

  tearDown(() {
    try {
      loginModel!.dispose();
    } catch (_) {}
    loginModel = null;
  });

  group("auto sign in", () {
    test("user not authenticated wont emmit event", () async {
      when(() => mockAuthService.getUserToken()).thenAnswer((_) async => null);
      await loginModel!.autoSignIn();
      expect(loginModel!.eventStream, neverEmits(anything));
      loginModel!.dispose();
    });

    test("user authenticated but not registered will emit event", () async {
      when(() => mockAuthService.getUserToken()).thenAnswer((_) async => token);
      when(() => mockUserRepository.get()).thenAnswer(
        (_) async => throw const DatabaseNotFoundException(),
      );
      await loginModel!.autoSignIn();
      expect(loginModel!.eventStream, emits(LoginEvent.navigateToSignUp));
    });

    test("doctor authenticated emits event", () async {
      when(() => mockAuthService.getUserToken()).thenAnswer((_) async => token);
      when(() => mockUserRepository.get()).thenAnswer(
        (_) async => user.copyWith(isDoctor: true),
      );
      await loginModel!.autoSignIn();
      expect(loginModel!.eventStream, emits(LoginEvent.navigateToDoctorHome));
    });

    test("patient authenticated emits event", () async {
      when(() => mockAuthService.getUserToken()).thenAnswer((_) async => token);
      when(() => mockUserRepository.get()).thenAnswer(
        (_) async => user.copyWith(isDoctor: false),
      );
      await loginModel!.autoSignIn();
      expect(loginModel!.eventStream, emits(LoginEvent.navigateToPatientHome));
    });
  });

  group("auto sign in", () {
    final phoneCredential = AuthPhoneCredential(
      phoneNumber: user.phoneNumber,
      verificationId: "some verification id",
      smsCode: "some sms code",
    );
    final userCredential = AuthUserCredential(
      token: token,
      user: AuthUser(
        uid: user.uid,
        phoneNumber: user.phoneNumber,
      ),
    );
    test("doctor sign in emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer((_) async {});
      when(() => mockUserRepository.get()).thenAnswer(
        (_) async => user.copyWith(isDoctor: true),
      );
      await loginModel!.signIn(phoneCredential);
      expect(
        loginModel!.eventStream,
        emitsInOrder([
          LoginEvent.showSnackbarMessage,
          LoginEvent.navigateToDoctorHome,
        ]),
      );
      assert(loginModel!.snackbarMessage == "Login bem sucedido!");
      assert(loginModel!.isLoadingSignIn == false);
    });
    test("patient sign in emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer((_) async {});
      when(() => mockUserRepository.get()).thenAnswer(
        (_) async => user.copyWith(isDoctor: false),
      );
      await loginModel!.signIn(phoneCredential);
      expect(
        loginModel!.eventStream,
        emitsInOrder([
          LoginEvent.showSnackbarMessage,
          LoginEvent.navigateToPatientHome,
        ]),
      );
      assert(loginModel!.snackbarMessage == "Login bem sucedido!");
      assert(loginModel!.isLoadingSignIn == false);
    });
    test("user not found emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer((_) async {});
      when(() => mockUserRepository.get()).thenAnswer(
        (_) async => throw const DatabaseNotFoundException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.navigateToSignUp));
      assert(loginModel!.isLoadingSignIn == false);
    });

    test("ApiUserNotRegisteredException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer(
        (_) async => throw const ApiUserNotRegisteredException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.navigateToSignUp));
      assert(loginModel!.isLoadingSignIn == false);
    });

    test("ApiUserNotRegisteredException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer(
        (_) async => throw const ApiUserNotRegisteredException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.navigateToSignUp));
      assert(loginModel!.isLoadingSignIn == false);
    });

    test("ApiTimeoutException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer(
        (_) async => throw const ApiTimeoutException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.isLoadingSignIn == false);
      assert(loginModel!.snackbarMessage ==
          "Ocorreu um erro ao tentar se conectar ao servidor. Por favor, tente novamente mais tarde ou entre em contato com o desenvolvedor.");
    });

    test("ApiConnectionException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer(
        (_) async => throw const ApiConnectionException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.isLoadingSignIn == false);
      assert(loginModel!.snackbarMessage ==
          "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet");
    });

    test("ApiException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => userCredential,
      );
      when(() => mockUserRepository.sync()).thenAnswer(
        (_) async => throw const ApiException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.isLoadingSignIn == false);
      assert(loginModel!.snackbarMessage ==
          "Ocorreu um erro desconhecido ao tentar fazer login. Tente novamente mais tarde ou entre em contato com o desenvolvedor");
    });

    test("AuthInvalidSignInCodeException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => throw const AuthInvalidSignInCodeException(),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.isLoadingSignIn == false);
      assert(loginModel!.snackbarMessage ==
          "O código digitado não é válido. Certifique-se de que o código informado é o mesmo código de seis dígitos recebido por SMS");
    });

    test("AuthException emits event", () async {
      when(() => mockAuthService.signInWithCredential(phoneCredential)).thenAnswer(
        (_) async => throw const AuthException(message: "", code: ""),
      );
      await loginModel!.signIn(phoneCredential);
      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.isLoadingSignIn == false);
      assert(loginModel!.snackbarMessage ==
          "Ocorreu um erro desconhecido ao tentar validar o código por SMS. Por favor, tente novamente mais tarde ou entre em contato com o desenvolvedor.");
    });
  });

  group("send verification code", () {
    test("code sent emits event", () async {
      const verificationId = "some id";

      when(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).thenAnswer((_) async {});

      await loginModel!.sendVerificationCode();

      final captured = verify(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: captureAny(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).captured.first as void Function(String);
      captured(verificationId);

      expect(loginModel!.eventStream, emits(LoginEvent.startCodeTimer));
      assert(loginModel!.isLoadingSendindCode == false);
      assert(loginModel!.codeVerificationId == verificationId);
    });

    test("on auto retrieval completed calls sign in", () async {
      final credential = AuthPhoneCredential(
        phoneNumber: user.phoneNumber,
        verificationId: "some id",
        smsCode: "some code",
      );

      when(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).thenAnswer((_) async {});

      await loginModel!.sendVerificationCode();

      final captured = verify(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: captureAny(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).captured.first as void Function(AuthPhoneCredential);

      when(() => mockAuthService.signInWithCredential(credential))
          .thenAnswer((_) async => throw const AuthException(message: "", code: ""));
      captured(credential);

      assert(loginModel!.isLoadingSendindCode == true);
      assert(loginModel!.verificationCode == credential.smsCode);

      verify(() => mockAuthService.signInWithCredential(credential));
    });

    test("error that is not AuthAutoRetrievalFailedExceptions emits event", () async {
      when(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).thenAnswer((_) async {});

      await loginModel!.sendVerificationCode();

      final captured = verify(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: captureAny(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).captured.first as void Function(AuthException);
      captured(const AuthException(message: "", code: ""));

      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.snackbarMessage ==
          "Ocorreu um erro desconhecido ao tentar enviar um SMS para o seu telefone. Tente novamente mais tarde ou entre em contato com o desenvolvedor");
      assert(loginModel!.isLoadingSendindCode == false);
    });

    test("error that AuthAutoRetrievalFailedExceptions doesnt emit event", () async {
      when(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).thenAnswer((_) async {});

      await loginModel!.sendVerificationCode();

      final captured = verify(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: captureAny(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).captured.first as void Function(AuthException);
      captured(const AuthAutoRetrievalFailedException());

      expect(loginModel!.eventStream, neverEmits(anything));
      loginModel!.dispose();
    });
  });
}
