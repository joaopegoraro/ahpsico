import 'package:ahpsico/services/auth/token.dart';
import 'package:ahpsico/services/auth/auth_user.dart';

class AuthUserCredential {
  const AuthUserCredential({
    required this.token,
    required this.user,
  });

  final AuthToken token;
  final AuthUser user;
}

class AuthPhoneCredential {
  const AuthPhoneCredential({
    required this.phoneNumber,
    required this.verificationId,
    required this.smsCode,
  });

  final String phoneNumber;
  final String verificationId;
  final String smsCode;
}
