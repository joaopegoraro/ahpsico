class ApiError implements Exception {
  const ApiError({
    this.message,
    this.code,
  });

  final String? message;
  final String? code;

  @override
  String toString() {
    return "ApiError($code): $message";
  }
}

class ApiUnauthorizedError extends ApiError {
  const ApiUnauthorizedError({String? message})
      : super(
          message: "You are not authorized to perform this request: $message",
          code: "api_unauthorized",
        );
}

class ApiConnectionError extends ApiError {
  const ApiConnectionError({String? message})
      : super(
          message: "The request suffered a connection problem: $message",
          code: "api_connection_failure",
        );
}

class ApiBadRequestError extends ApiError {
  const ApiBadRequestError({String? message})
      : super(
          message: "Something is not right with the request: $message",
          code: "api_bad_request",
        );
}

class ApiUserNotRegisteredError extends ApiError {
  const ApiUserNotRegisteredError({String? message})
      : super(
          message: "The user can't login because it is not yet registered: $message",
          code: "api_user_not_registered",
        );
}

class ApiUserAlreadyRegisteredError extends ApiError {
  const ApiUserAlreadyRegisteredError({String? message})
      : super(
          message: "The user can't sign up because it is already registered: $message",
          code: "api_user_already_registered",
        );
}

class ApiInviteAlreadySentError extends ApiError {
  const ApiInviteAlreadySentError({String? message})
      : super(
          message: "This invite was already sent to the patient: $message",
          code: "api_invite_already_sent",
        );
}

class ApiInvitesNotFoundError extends ApiError {
  const ApiInvitesNotFoundError({String? message})
      : super(
          message: "No invites were found for this account: $message",
          code: "api_invites_not_found",
        );
}

class ApiPatientNotRegisteredError extends ApiError {
  const ApiPatientNotRegisteredError({String? message})
      : super(
          message: "There are not patients registered with this phone number yet: $message",
          code: "api_patient_not_registered",
        );
}

class ApiPatientAlreadyWithDoctorError extends ApiError {
  const ApiPatientAlreadyWithDoctorError({String? message})
      : super(
          message: "You can't send the invite, the patient is already with the doctor: $message",
          code: "api_patient_already_with_doctor",
        );
}

class ApiSessionAlreadyBookedError extends ApiError {
  const ApiSessionAlreadyBookedError({String? message})
      : super(
          message: "There already is a session booked at this time",
          code: "api_session_already_booked",
        );
}
