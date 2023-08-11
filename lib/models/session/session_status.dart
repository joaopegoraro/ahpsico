enum SessionStatus {
  notConfirmed(0),
  confirmed(1),
  canceled(2),
  concluded(3);

  const SessionStatus(this.value);
  final int value;

  factory SessionStatus.fromValue(
    int? value, {
    SessionStatus fallback = SessionStatus.notConfirmed,
  }) {
    return SessionStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }
}
