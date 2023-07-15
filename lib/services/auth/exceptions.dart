class AuthException implements Exception {
  const AuthException({
    required this.message,
    required this.code,
  });

  final String? message;
  final String code;

  @override
  String toString() {
    return "AuthException($code): $message";
  }
}

class AuthInvalidSignInCodeException extends AuthException {
  const AuthInvalidSignInCodeException({String? message})
      : super(
          message: "The supplied SMS code isn't valid: $message",
          code: "auth_invalid_sign_in_code",
        );
}
