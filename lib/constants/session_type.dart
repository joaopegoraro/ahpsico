enum SessionType {
  individual(0),
  monthly(1);

  const SessionType(this.value);
  final int value;

  factory SessionType.fromValue(
    int value, {
    SessionType fallback = SessionType.individual,
  }) {
    return SessionType.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }
}
