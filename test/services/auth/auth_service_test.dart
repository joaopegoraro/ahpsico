import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/services/auth/credentials.dart';
import 'package:ahpsico/services/auth/exceptions.dart';
import 'package:ahpsico/services/auth/token.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockFirebasePhoneAuthCredential extends Mock implements firebase_auth.PhoneAuthCredential {}

class MockFirebaseUserCredential extends Mock implements firebase_auth.UserCredential {}

void main() {
  final mockFirebaseAuth = MockFirebaseAuth();
  final AuthService authService = AuthServiceImpl(mockFirebaseAuth);

  final mockFirebaseUser = MockFirebaseUser();
  final mockFirebasePhoneAuthCredential = MockFirebasePhoneAuthCredential();
  final mockFirebaseUserCredential = MockFirebaseUserCredential();
  const mockPhoneNumber = "some phone number";
  const mockSmsCode = "some sms code";
  const mockVerificationId = "some verification id";

  setUp(() {
    registerFallbackValue(mockFirebasePhoneAuthCredential);
  });

  group("getUserToken", () {
    Future<void> testGetUserToken({
      required bool signOutShouldHappen,
      required firebase_auth.User? currentUserReturn,
      required String getIdTokenReturn,
      required void Function(AuthToken?) assertToken,
    }) async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(currentUserReturn);
      when(() => mockFirebaseUser.getIdToken()).thenAnswer((_) async => getIdTokenReturn);
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      final authToken = await authService.getUserToken();
      if (signOutShouldHappen) {
        verify(() => mockFirebaseAuth.signOut());
      } else {
        verifyNever(() => mockFirebaseAuth.signOut());
      }
      assertToken(authToken);
    }

    test("when FirebaseAuth.currentUser returns null, then signOut and return null", () async {
      await testGetUserToken(
        signOutShouldHappen: true,
        currentUserReturn: null,
        getIdTokenReturn: "",
        assertToken: (authToken) {
          assert(authToken == null);
        },
      );
    });

    test("when FirebaseAuth.currentUser?.getIdToken() returns an empty string, then signOut and return null", () async {
      await testGetUserToken(
        signOutShouldHappen: true,
        currentUserReturn: mockFirebaseUser,
        getIdTokenReturn: "",
        assertToken: (authToken) {
          assert(authToken == null);
        },
      );
    });

    test("when FirebaseAuth.currentUser?.getIdToken() returns a non-empty string, then return it", () async {
      const expectedIdToken = "some id token";
      await testGetUserToken(
        signOutShouldHappen: false,
        currentUserReturn: mockFirebaseUser,
        getIdTokenReturn: expectedIdToken,
        assertToken: (authToken) {
          assert(authToken?.idToken == expectedIdToken);
        },
      );
    });
  });

  group("sendPhoneVerificationCode", () {
    final mockFirebaseAuthException = firebase_auth.FirebaseAuthException(
      code: "some code",
      message: "some message",
    );

    Future<void> testSendPhoneVerificationCode({
      required String? verificationIdReturn,
      required String? smsCodeReturn,
      required void Function(List<dynamic>) onCapture,
      void Function(String verificationId)? onCodeSent,
      void Function(AuthException exception)? onFailed,
      void Function(AuthPhoneCredential credential)? onAutoRetrievalCompleted,
      void Function(String verificationId)? onAutoRetrievalTimeout,
      bool captureCodeSent = false,
      bool captureVerificationFailed = false,
      bool captureVerificationCompleted = false,
      bool captureCodeAutoRetrievalTimeout = false,
    }) async {
      when(() => mockFirebasePhoneAuthCredential.verificationId).thenReturn(verificationIdReturn);
      when(() => mockFirebasePhoneAuthCredential.smsCode).thenReturn(smsCodeReturn);
      when(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: mockPhoneNumber,
            verificationCompleted: any(named: "verificationCompleted"),
            verificationFailed: any(named: "verificationFailed"),
            codeSent: any(named: "codeSent"),
            codeAutoRetrievalTimeout: any(named: "codeAutoRetrievalTimeout"),
          )).thenAnswer((_) async {});
      await authService.sendPhoneVerificationCode(
          phoneNumber: mockPhoneNumber,
          onCodeSent: (verificationId) {
            if (onCodeSent == null) {
              assert(false);
            } else {
              onCodeSent(verificationId);
            }
          },
          onFailed: (err) {
            if (onFailed == null) {
              assert(false);
            } else {
              onFailed(err);
            }
          },
          onAutoRetrievalCompleted: (credential) {
            if (onAutoRetrievalCompleted == null) {
              assert(false);
            } else {
              onAutoRetrievalCompleted(credential);
            }
          },
          onAutoRetrievalTimeout: (verificationId) {
            if (onAutoRetrievalTimeout == null) {
              assert(false);
            } else {
              onAutoRetrievalTimeout(verificationId);
            }
          });
      final captured = verify(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: mockPhoneNumber,
            verificationCompleted: captureVerificationCompleted
                ? captureAny(named: "verificationCompleted")
                : any(named: "verificationCompleted"),
            verificationFailed:
                captureVerificationFailed ? captureAny(named: "verificationFailed") : any(named: "verificationFailed"),
            codeSent: captureCodeSent ? captureAny(named: "codeSent") : any(named: "codeSent"),
            codeAutoRetrievalTimeout: captureCodeAutoRetrievalTimeout
                ? captureAny(named: "codeAutoRetrievalTimeout")
                : any(named: "codeAutoRetrievalTimeout"),
          )).captured;
      onCapture(captured);
    }

    test("auto-verification completed successfuly calls onAutoRetrievalCompleted", () async {
      await testSendPhoneVerificationCode(
        verificationIdReturn: mockVerificationId,
        smsCodeReturn: mockSmsCode,
        captureVerificationCompleted: true,
        onAutoRetrievalCompleted: (credential) {
          assert(credential.phoneNumber == mockPhoneNumber);
          assert(credential.verificationId == mockVerificationId);
          assert(credential.smsCode == mockSmsCode);
        },
        onCapture: (captured) {
          final verificationCompleted = captured.first as firebase_auth.PhoneVerificationCompleted;
          verificationCompleted(mockFirebasePhoneAuthCredential);
        },
      );
    });

    test("verification failed calls onFailed", () async {
      await testSendPhoneVerificationCode(
        verificationIdReturn: mockVerificationId,
        smsCodeReturn: mockSmsCode,
        captureVerificationFailed: true,
        onFailed: (err) {
          assert(err.code == mockFirebaseAuthException.code);
          assert(err.message == mockFirebaseAuthException.message);
        },
        onCapture: (captured) {
          final verificationFailed = captured.first as firebase_auth.PhoneVerificationFailed;
          verificationFailed(mockFirebaseAuthException);
        },
      );
    });

    test("code sent calls onCodeSent", () async {
      await testSendPhoneVerificationCode(
        verificationIdReturn: mockVerificationId,
        smsCodeReturn: mockSmsCode,
        captureCodeSent: true,
        onCodeSent: (id) {
          assert(id == mockVerificationId);
        },
        onCapture: (captured) {
          final codeSent = captured.first as firebase_auth.PhoneCodeSent;
          codeSent(mockVerificationId, null);
        },
      );
    });

    test("auto-verification timeout calls onAutoRetrievalTimeout", () async {
      await testSendPhoneVerificationCode(
        verificationIdReturn: mockVerificationId,
        smsCodeReturn: mockSmsCode,
        captureCodeAutoRetrievalTimeout: true,
        onAutoRetrievalTimeout: (id) {
          assert(id == mockVerificationId);
        },
        onCapture: (captured) {
          final codeAutoRetrievalTimeout = captured.first as firebase_auth.PhoneCodeAutoRetrievalTimeout;
          codeAutoRetrievalTimeout(mockVerificationId);
        },
      );
    });
  });

  group("signInWithCredential", () {
    const mockedAuthPhoneCredential = AuthPhoneCredential(
      phoneNumber: mockPhoneNumber,
      verificationId: mockVerificationId,
      smsCode: mockSmsCode,
    );

    test("signin throws exception with code invalid-verification-code throws", () async {
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) => throw firebase_auth.FirebaseAuthException(code: "invalid-verification-code"));
      try {
        await authService.signInWithCredential(mockedAuthPhoneCredential);
      } on AuthInvalidSignInCodeException catch (_) {
        assert(true);
      }
    });

    test("succesful signin returns credentials", () async {
      const uid = "some uid";
      const token = "some token";
      when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((_) async => mockFirebaseUserCredential);
      when(() => mockFirebaseUserCredential.user).thenReturn(mockFirebaseUser);
      when(() => mockFirebaseUser.getIdToken()).thenAnswer((_) async => token);
      when(() => mockFirebaseUser.uid).thenReturn(uid);
      final credentials = await authService.signInWithCredential(mockedAuthPhoneCredential);
      assert(credentials.token.idToken == token);
      assert(credentials.user.uid == uid);
      assert(credentials.user.phoneNumber == mockPhoneNumber);
      verifyNever(() => mockFirebaseAuth.signOut());
    });
  });
}
