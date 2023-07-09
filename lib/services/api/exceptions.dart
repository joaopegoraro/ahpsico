class ApiException implements Exception {
  const ApiException({
    this.message,
    this.code,
  });

  final String? message;
  final String? code;

  @override
  String toString() {
    return "ApiException($code): $message";
  }
}

class ApiUnauthorizedException extends ApiException {
  const ApiUnauthorizedException({String? message})
      : super(
          message: "You are not authorized to perform this request: $message",
          code: "api_unauthorized",
        );
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException({String? message})
      : super(
          message: "The request suffered timeout: $message",
          code: "api_timeout",
        );
}

class ApiConnectionException extends ApiException {
  const ApiConnectionException({String? message})
      : super(
          message: "The request suffered a connection problem: $message",
          code: "api_connection_failure",
        );
}

class ApiUserNotRegisteredException extends ApiException {
  const ApiUserNotRegisteredException({String? message})
      : super(
          message: "The user can't login because it is not yet registered: $message",
          code: "api_user_not_registered",
        );
}

class ApiEncodeRequestException extends ApiException {
  const ApiEncodeRequestException({String? message})
      : super(
          message: "There was a problem trying to encode the request body: $message",
          code: "api_request_encode_error",
        );
}

class ApiDecodeResponseException extends ApiException {
  const ApiDecodeResponseException({String? message})
      : super(
          message: "There was a problem trying to decode the response body: $message",
          code: "api_response_decode_error",
        );
}
