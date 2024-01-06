enum SessionType {
  individual("INDIVIDUAL"),
  monthly("MONTHLY");

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

  bool get isIndividual {
    return this == individual;
  }

  bool get isMonthly {
    return this == monthly;
  }
}
