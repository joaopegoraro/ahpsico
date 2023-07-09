import 'package:ahpsico/services/auth/credentials.dart';
import 'package:ahpsico/services/auth/exceptions.dart';
import 'package:ahpsico/services/auth/token.dart';
import 'package:ahpsico/services/auth/auth_user.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthService {
  /// Returns the user authentication token, or null if the user is not authenticated
  Future<AuthToken?> getUserToken();

  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AuthException exception) onFailed,
    required void Function(AuthPhoneCredential credential) onAutoRetrievalCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  });

  /// throws [AuthException] :
  /// - [AuthInvalidSignInCodeException] when the provided sms code is not valid;
  /// - [AuthInvalidVerificationCodeException] when the provided verification code is not valid;
  /// - [AuthSignInFailedException] when something unexpected happeneded when trying to sign in
  Future<AuthUserCredential> signInWithCredential(AuthPhoneCredential phoneCredential);
}

final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = firebase_auth.FirebaseAuth.instance;
  return AuthServiceImpl(firebaseAuth);
});

final class AuthServiceImpl implements AuthService {
  const AuthServiceImpl(this._firebaseAuth);

  final firebase_auth.FirebaseAuth _firebaseAuth;

  @override
  Future<AuthToken?> getUserToken() async {
    final idToken = await _firebaseAuth.currentUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      await _firebaseAuth.signOut();
      return null;
    }
    return AuthToken(idToken);
  }

  @override
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AuthException exception) onFailed,
    required void Function(AuthPhoneCredential credential) onAutoRetrievalCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    return await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebasePhoneAuthCredential) {
        final verificationId = firebasePhoneAuthCredential.verificationId;
        final smsCode = firebasePhoneAuthCredential.smsCode;
        if (verificationId == null || verificationId.isEmpty) {
          return onFailed(const AuthAutoRetrievalFailedException());
        }
        if (smsCode == null || smsCode.isEmpty) {
          return onFailed(const AuthAutoRetrievalFailedException());
        }
        final phoneCredential = AuthPhoneCredential(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
          smsCode: smsCode,
        );
        onAutoRetrievalCompleted(phoneCredential);
      },
      verificationFailed: (error) {
        final authException = AuthException(message: error.message, code: error.code);
        onFailed(authException);
      },
      codeSent: (verificationId, forceResendingToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
    );
  }

  /// throws [AuthInvalidSignInCodeException] when the provided sms code is not valid;
  ///
  /// throws [AuthInvalidVerificationCodeException] when the provided verification code is not valid;
  ///
  /// throws [AuthSignInFailedException] when something unexpected happeneded when trying to sign in
  @override
  Future<AuthUserCredential> signInWithCredential(AuthPhoneCredential phoneCredential) async {
    final firebasePhoneCredential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: phoneCredential.verificationId,
      smsCode: phoneCredential.smsCode,
    );

    firebase_auth.UserCredential firebaseUserCredential;
    try {
      firebaseUserCredential = await _firebaseAuth.signInWithCredential(firebasePhoneCredential);
    } on firebase_auth.FirebaseAuthException catch (err, stackTrace) {
      switch (err.code) {
        case "invalid-verification-code":
          throw AuthInvalidSignInCodeException(message: err.message);
        case "invalid-verification-id":
          throw AuthInvalidVerificationCodeException(message: err.message);
        default:
          AuthSignInFailedException(message: err.message).throwWithStackTrace(stackTrace);
      }
    }

    final firebaseUser = firebaseUserCredential.user;
    if (firebaseUser == null) {
      await _firebaseAuth.signOut();
      throw const AuthSignInFailedException(message: "FirebaseUserCredential returned a null user");
    }

    final idToken = await firebaseUser.getIdToken();
    if (idToken.isEmpty) {
      await _firebaseAuth.signOut();
      throw const AuthSignInFailedException(message: "FirebaseUser returned an empty id token");
    }
    final token = AuthToken(idToken);

    final user = AuthUser(
      uid: firebaseUser.uid,
      phoneNumber: phoneCredential.phoneNumber,
    );

    return AuthUserCredential(token: token, user: user);
  }
}
