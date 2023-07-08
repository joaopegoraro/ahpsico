import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthRepository {
  abstract final Stream<User?> authStateChanges;

  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    Function(String verificationId, int? resendToken)? onCodeSent,
    Function(FirebaseAuthException exception)? onFailed,
    Function(PhoneAuthCredential credential)? onAutoRetrievalCompleted,
    Function(String verificationId)? onAutoRetrievalTimeout,
  });
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential);

  Future<UserCredential> validateVerificationCode({
    required String verificationId,
    required String code,
  });
}

final class AuthRepositoryImpl implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  final Stream<User?> authStateChanges = FirebaseAuth.instance.authStateChanges();

  @override
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    Function(String verificationId, int? resendToken)? onCodeSent,
    Function(FirebaseAuthException exception)? onFailed,
    Function(PhoneAuthCredential credential)? onAutoRetrievalCompleted,
    Function(String verificationId)? onAutoRetrievalTimeout,
  }) async {
    return await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (phoneAuthCredential) {
        onAutoRetrievalCompleted?.call(phoneAuthCredential);
      },
      verificationFailed: (error) {
        onFailed?.call(error);
      },
      codeSent: (verificationId, forceResendingToken) {
        onCodeSent?.call(verificationId, forceResendingToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onAutoRetrievalTimeout?.call(verificationId);
      },
    );
  }

  @override
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> validateVerificationCode({
    required String verificationId,
    required String code,
  }) async {
    final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
    return signInWithCredential(credential);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
