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

class ApiConnectionException extends ApiException {
  const ApiConnectionException({String? message})
      : super(
          message: "The request suffered a connection problem: $message",
          code: "api_connection_failure",
        );
}

class ApiBadRequestException extends ApiException {
  const ApiBadRequestException({String? message})
      : super(
          message: "Something is not right with the request: $message",
          code: "api_bad_request",
        );
}

class ApiUserNotRegisteredException extends ApiException {
  const ApiUserNotRegisteredException({String? message})
      : super(
          message: "The user can't login because it is not yet registered: $message",
          code: "api_user_not_registered",
        );
}

class ApiUserAlreadyRegisteredException extends ApiException {
  const ApiUserAlreadyRegisteredException({String? message})
      : super(
          message: "The user can't sign up because it is already registered: $message",
          code: "api_user_already_registered",
        );
}

class ApiInviteAlreadySentException extends ApiException {
  const ApiInviteAlreadySentException({String? message})
      : super(
          message: "This invite was already sent to the patient: $message",
          code: "api_invite_already_sent",
        );
}

class ApiInvitesNotFoundException extends ApiException {
  const ApiInvitesNotFoundException({String? message})
      : super(
          message: "No invites were found for this account: $message",
          code: "api_invites_not_found",
        );
}

class ApiPatientNotRegisteredException extends ApiException {
  const ApiPatientNotRegisteredException({String? message})
      : super(
          message: "There are not patients registered with this phone number yet: $message",
          code: "api_patient_not_registered",
        );
}

class ApiPatientAlreadyWithDoctorException extends ApiException {
  const ApiPatientAlreadyWithDoctorException({String? message})
      : super(
          message: "You can't send the invite, the patient is already with the doctor: $message",
          code: "api_patient_already_with_doctor",
        );
}

class ApiSessionAlreadyBookedException extends ApiException {
  const ApiSessionAlreadyBookedException({String? message})
      : super(
          message: "There already is a session booked at this time",
          code: "api_session_already_booked",
        );
}
