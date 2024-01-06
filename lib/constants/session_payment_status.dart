enum SessionPaymentStatus {
  notPayed(0),
  payed(1);

  const SessionPaymentStatus(this.value);
  final int value;

  bool get isNotPayed => this == SessionPaymentStatus.notPayed;
  bool get isPayed => this == SessionPaymentStatus.payed;

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
