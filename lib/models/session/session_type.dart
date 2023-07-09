enum SessionType {
  monthly("MONTHLY"),
  individual("INDIVIDUAL");

  const SessionType(this.value);
  final String value;

  factory SessionType.fromValue(
    String value, {
    SessionType fallback = SessionType.individual,
  }) {
    return SessionType.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }
}
