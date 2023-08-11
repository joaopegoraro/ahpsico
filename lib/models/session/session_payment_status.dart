enum SessionPaymentStatus {
  notPayed(0),
  payed(1);

  const SessionPaymentStatus(this.value);
  final int value;

  factory SessionPaymentStatus.fromValue(
    int? value, {
    SessionPaymentStatus fallback = SessionPaymentStatus.notPayed,
  }) {
    return SessionPaymentStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }
}
