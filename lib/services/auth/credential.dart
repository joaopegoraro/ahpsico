class AuthPhoneCredential {
  AuthPhoneCredential({
    required this.verificationId,
    required this.smsCode,
  });

  final String verificationId;
  final String smsCode;
}
