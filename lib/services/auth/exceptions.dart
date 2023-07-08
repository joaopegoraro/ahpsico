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
  const AuthSignInFailedException()
      : super(
          message: "Houve um problema ao tentar fazer login, por favor, "
              "tente novamente mais tarde ou entre em contato com o desenvolvedor",
          code: "auth_sign_in_failed",
        );
}

class AuthAutoRetrievalFailedException extends AuthException {
  const AuthAutoRetrievalFailedException()
      : super(
          message: "Houve um problema ao tentar validar o código automaticamente, "
              "por favor, digite o código recebido por SMS manualmente",
          code: "auth_auto_retrieval_failed",
        );
}

class AuthInvalidVerificationCodeException extends AuthException {
  const AuthInvalidVerificationCodeException()
      : super(
          message: "O id de verificação não é válido",
          code: "auth_invalid_sign_in_verification_id",
        );
}

class AuthInvalidSignInCodeException extends AuthException {
  const AuthInvalidSignInCodeException()
      : super(
          message: "O código inserido não é válido",
          code: "auth_invalid_sign_in_code",
        );
}
