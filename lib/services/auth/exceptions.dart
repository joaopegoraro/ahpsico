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

class AuthSignInFailedException extends AuthException {
  const AuthSignInFailedException({String? message})
      : super(
          message: "There was a problem trying to sign in: $message",
          code: "auth_sign_in_failed",
        );
}

class AuthAutoRetrievalFailedException extends AuthException {
  const AuthAutoRetrievalFailedException({String? message})
      : super(
          message: "There was a problem trying to automatically retrieve the SMS code: $message",
          code: "auth_auto_retrieval_failed",
        );
}

class AuthInvalidVerificationCodeException extends AuthException {
  const AuthInvalidVerificationCodeException({String? message})
      : super(
          message: "The supplied verification ID isn't valid: $message",
          code: "auth_invalid_sign_in_verification_id",
        );
}

class AuthInvalidSignInCodeException extends AuthException {
  const AuthInvalidSignInCodeException({String? message})
      : super(
          message: "The supplied SMS code isn't valid: $message",
          code: "auth_invalid_sign_in_code",
        );
}
