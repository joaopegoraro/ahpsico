import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/services/auth/credential.dart';
import 'package:ahpsico/services/auth/exceptions.dart';
import 'package:ahpsico/services/auth/token.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AuthRepository {
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(AuthException exception) onFailed,
    required Function(AuthPhoneCredential credential) onAutoRetrievalCompleted,
    Function(String verificationId)? onAutoRetrievalTimeout,
  });

  /// throws [AuthSignInFailedException]
  Future<AuthToken> signInWithCredential(AuthPhoneCredential credential);

  /// throws [AuthSignInFailedException]
  Future<AuthToken> validateVerificationCode({
    required String verificationId,
    required String code,
  });
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);
  final AuthService _authService;

  @override
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(AuthException exception) onFailed,
    required Function(AuthPhoneCredential credential) onAutoRetrievalCompleted,
    Function(String verificationId)? onAutoRetrievalTimeout,
  }) async {
    return await _authService.sendPhoneVerificationCode(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onFailed: onFailed,
      onAutoRetrievalCompleted: onAutoRetrievalCompleted,
      onAutoRetrievalTimeout: onAutoRetrievalTimeout ?? (_) {},
    );
  }

  @override
  Future<AuthToken> signInWithCredential(AuthPhoneCredential credential) async {
    try {
      return _authService.signInWithCredential(credential);
    } on AuthSignInFailedException {
      rethrow;
    }
  }

  @override
  Future<AuthToken> validateVerificationCode({
    required String verificationId,
    required String code,
  }) async {
    final phoneCredential = AuthPhoneCredential(
      verificationId: verificationId,
      smsCode: code,
    );
    try {
      return await signInWithCredential(phoneCredential);
    } on AuthSignInFailedException {
      rethrow;
    }
  }
}
