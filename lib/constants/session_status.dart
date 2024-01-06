enum SessionStatus {
  notConfirmed("NOT_CONFIRMED"),
  confirmedByPatient("CONFIRMED_BY_PATIENT"),
  confirmedByDoctor("CONFIRMED_BY_DOCTOR"),
  confirmed("CONFIRMED"),
  canceled("CANCELED"),
  concluded("CONCLUDED");

  const SessionStatus(this.value);
  final String value;

  factory SessionStatus.fromValue(
    String? value, {
    SessionStatus fallback = SessionStatus.notConfirmed,
  }) {
    return SessionStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }

  bool get isNotConfirmed {
    return this == notConfirmed;
  }

  bool get isConfirmedByPatient {
    return this == confirmedByPatient;
  }

  bool get isConfirmedByDoctor {
    return this == confirmedByDoctor;
  }

  bool get isConfirmed {
    return this == confirmed;
  }

  bool get isCanceled {
    return this == canceled;
  }

  bool get isConcluded {
    return this == concluded;
  }

  bool isIn(List<SessionStatus> statusList) {
    return statusList.contains(this);
  }

  bool get isOver {
    return isIn([canceled, concluded]);
  }
}
