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
import 'package:ahpsico/utils/mask_formatters.dart';
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
    phoneNumber: faker.phoneNumber.random.fromPattern([MaskFormatters.phoneMaskPattern]),
    isDoctor: false,
  );

  setUpAll(() {
    registerFallbackValue(
      const AuthPhoneCredential(
        phoneNumber: "",
        verificationId: "",
        smsCode: "",
      ),
    );
  });

  setUp(() {
    loginModel = LoginModel(mockUserRepository, mockAuthService, null);
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

  group("sign in", () {
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
          .thenAnswer((_) async => throw const DatabaseNotFoundException());
      captured(credential);

      assert(loginModel!.isLoadingSendindCode == true);
      assert(loginModel!.verificationCode == credential.smsCode);

      verify(() => mockAuthService.signInWithCredential(credential));
    });

    test("error that is not auto retrieval railed emits event", () async {
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
      captured(const AuthInvalidSignInCodeException());

      expect(loginModel!.eventStream, emits(LoginEvent.showSnackbarError));
      assert(loginModel!.snackbarMessage ==
          "O código digitado não é válido. Certifique-se de que o código informado é o mesmo código de seis dígitos recebido por SMS");
      assert(loginModel!.isLoadingSendindCode == false);
    });

    test("unknown error emits event", () async {
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
          "Ocorreu um erro ao tentar enviar um SMS para o seu telefone. Tente novamente mais tarde ou entre em contato com o desenvolvedor");
      assert(loginModel!.isLoadingSendindCode == false);
    });
  });

  test("mask phone masks succesfully", () {
    const phone = "99999999999";
    final masked = loginModel!.maskPhone(phone);
    assert(masked == "(99) 99999-9999");
  });

  group("validate phone", () {
    test("valid phone sets isPhoneValid to true", () {
      String phone = "99 99999-9999";
      loginModel!.validatePhone(phone);
      assert(loginModel!.isPhoneValid);

      phone = "99999999999";
      loginModel!.validatePhone(phone);
      assert(loginModel!.isPhoneValid);

      phone = "(99) 99999-9999";
      loginModel!.validatePhone(phone);
      assert(loginModel!.isPhoneValid);
    });

    test("invalid phone returns false", () {
      String phone = "9999";
      loginModel!.validatePhone(phone);
      assert(!loginModel!.isPhoneValid);

      phone = "(99) 89999-9999";
      loginModel!.validatePhone(phone);
      assert(!loginModel!.isPhoneValid);
    });
  });

  test("update phone", () {
    const phone = "99 99999-9999";
    assert(loginModel!.phoneNumber.isEmpty);
    assert(!loginModel!.isPhoneValid);
    loginModel!.updatePhone(phone);
    assert(loginModel!.phoneNumber == phone);
    assert(loginModel!.isPhoneValid);

    expect(loginModel!.eventStream, emitsInOrder([LoginEvent.updatePhoneInputField]));
  });

  group("update code", () {
    test("valid code updates code and emits event", () {
      const code = "123456";
      assert(loginModel!.verificationCode.isEmpty);
      loginModel!.updateCode(code);
      assert(loginModel!.verificationCode == code);

      expect(loginModel!.eventStream, emitsInOrder([LoginEvent.updateCodeInputField]));
    });
    test("big code wont update code but still emits event", () {
      const code = "123456789";
      assert(loginModel!.verificationCode.isEmpty);
      loginModel!.updateCode(code);
      assert(loginModel!.verificationCode.isEmpty);

      expect(loginModel!.eventStream, emitsInOrder([LoginEvent.updateCodeInputField]));
    });
  });

  group("confirm text", () {
    test("valid code tries to sign in", () async {
      const code = "123456";
      loginModel!.updateCode(code);
      loginModel!.codeVerificationId = "some code verification id";

      when(() => mockAuthService.signInWithCredential(any()))
          .thenAnswer((_) async => throw const DatabaseNotFoundException());

      loginModel!.confirmText();

      verify(() => mockAuthService.signInWithCredential(any()));
    });

    test("valid phone sends verification code", () async {
      const phone = "99 99999-9999";
      loginModel!.updatePhone(phone);

      when(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: any(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          )).thenAnswer((_) async {});

      loginModel!.confirmText();

      verify(() => mockAuthService.sendPhoneVerificationCode(
            phoneNumber: any(named: "phoneNumber"),
            onCodeSent: any(named: "onCodeSent"),
            onFailed: any(named: "onFailed"),
            onAutoRetrievalCompleted: captureAny(named: "onAutoRetrievalCompleted"),
            onAutoRetrievalTimeout: any(named: "onAutoRetrievalTimeout"),
          ));
    });
  });

  group("update text", () {
    test("updates code", () {
      const text = "6";
      loginModel!.codeVerificationId = "some verification id";
      assert(loginModel!.verificationCode.isEmpty);
      loginModel!.updateText(text);
      assert(loginModel!.verificationCode == text);

      expect(loginModel!.eventStream, emitsInOrder([LoginEvent.updateCodeInputField]));
    });

    test("updates phone", () {
      const text = "9";
      const expectedPhone = "($text";
      assert(loginModel!.phoneNumber.isEmpty);
      loginModel!.updateText(text);
      assert(loginModel!.phoneNumber == expectedPhone);

      expect(loginModel!.eventStream, emitsInOrder([LoginEvent.updatePhoneInputField]));
    });
  });

  group("delete text", () {
    test("deletes code", () {
      const code = "123456";
      const expectedCode = "12345";
      loginModel!.updateCode(code);
      loginModel!.codeVerificationId = "some verification id";
      assert(loginModel!.verificationCode == code);
      loginModel!.deleteText();
      assert(loginModel!.verificationCode == expectedCode);

      expect(
          loginModel!.eventStream,
          emitsInOrder([
            LoginEvent.updateCodeInputField,
            LoginEvent.updateCodeInputField,
          ]));
    });

    test("deletes phone", () {
      const phone = "(99) 99999";
      const expectedPhone = "(99) 9999";
      loginModel!.updatePhone(phone);
      assert(loginModel!.phoneNumber == phone);
      loginModel!.deleteText();
      assert(loginModel!.phoneNumber == expectedPhone);

      expect(
          loginModel!.eventStream,
          emitsInOrder([
            LoginEvent.updatePhoneInputField,
            LoginEvent.updatePhoneInputField,
          ]));
    });
  });

  group("cancel code verification", () {
    test("code has been sent resets the code and verification id and returns false", () async {
      const code = "1234";
      const verificationId = "some verification id";
      loginModel!.updateCode(code);
      loginModel!.codeVerificationId = verificationId;
      assert(loginModel!.codeVerificationId == verificationId);
      assert(loginModel!.hasCodeBeenSent);
      assert(loginModel!.verificationCode == code);
      final canPopNavigation = await loginModel!.cancelCodeVerification();
      assert(!canPopNavigation);
      assert(loginModel!.codeVerificationId.isEmpty);
      assert(!loginModel!.hasCodeBeenSent);
      assert(loginModel!.verificationCode.isEmpty);
    });

    test("code has not been sent returns true", () async {
      assert(loginModel!.codeVerificationId.isEmpty);
      assert(!loginModel!.hasCodeBeenSent);
      assert(loginModel!.verificationCode.isEmpty);
      final canPopNavigation = await loginModel!.cancelCodeVerification();
      assert(canPopNavigation);
      assert(loginModel!.codeVerificationId.isEmpty);
      assert(!loginModel!.hasCodeBeenSent);
      assert(loginModel!.verificationCode.isEmpty);
    });
  });
}
