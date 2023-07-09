enum SessionStatus {
  confirmed("CONFIRMED"),
  notConfirmed("NOT_CONFIRMED"),
  canceled("CANCELED"),
  concluded("CONCLUDED");

  const SessionStatus(this.value);
  final String value;

  factory SessionStatus.fromValue(
    String value, {
    SessionStatus fallback = SessionStatus.notConfirmed,
  }) {
    return SessionStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }
}
