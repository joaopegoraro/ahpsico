import 'package:ahpsico/services/auth/credential.dart';
import 'package:ahpsico/services/auth/exceptions.dart';
import 'package:ahpsico/services/auth/token.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthService {
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(AuthException exception) onFailed,
    required Function(AuthPhoneCredential credential) onAutoRetrievalCompleted,
    required Function(String verificationId) onAutoRetrievalTimeout,
  });

  /// throws [AuthSignInFailedException]
  Future<AuthToken> signInWithCredential(AuthPhoneCredential credential);
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl();
});

final class AuthServiceImpl implements AuthService {
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;

  @override
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(AuthException exception) onFailed,
    required Function(AuthPhoneCredential credential) onAutoRetrievalCompleted,
    required Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    return await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebasePhoneAuthCredential) {
        final verificationId = firebasePhoneAuthCredential.verificationId;
        final smsCode = firebasePhoneAuthCredential.smsCode;
        if (verificationId == null || verificationId.isEmpty) {
          onFailed(AuthAutoRetrievalFailedException());
        }
        if (smsCode == null || smsCode.isEmpty) {
          onFailed(AuthAutoRetrievalFailedException());
        }
        final phoneCredential = AuthPhoneCredential(
          verificationId: verificationId!,
          smsCode: smsCode!,
        );
        onAutoRetrievalCompleted(phoneCredential);
      },
      verificationFailed: (error) {
        final authException = AuthException(message: error.message, code: error.code);
        onFailed(authException);
      },
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
    );
  }

  @override
  Future<AuthToken> signInWithCredential(AuthPhoneCredential credential) async {
    final firebasePhoneCredential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: credential.verificationId,
      smsCode: credential.smsCode,
    );
    final userCredential = await _auth.signInWithCredential(firebasePhoneCredential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw AuthSignInFailedException();
    }
    return AuthToken(idToken);
  }
}
