enum SessionPaymentType {
  particular("PARTICULAR"),
  clinic("CLINIC"),
  healthPlan("HEALTH_PLAN");

  const SessionPaymentType(this.value);
  final String value;

  factory SessionPaymentType.fromValue(
    String? value, {
    SessionPaymentType fallback = SessionPaymentType.particular,
  }) {
    return SessionPaymentType.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }

  bool get isParticular {
    return this == particular;
  }

  bool get isClinic {
    return this == clinic;
  }

  bool get isHealthPlan {
    return this == healthPlan;
  }
}
