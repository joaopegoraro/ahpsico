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

  bool get isNotConfirmed => this == notConfirmed;
  bool get isConfirmed => this == confirmed;
  bool get isCanceled => this == canceled;
  bool get isConcluded => this == concluded;

  bool isIn(List<SessionStatus> statusList) {
    return statusList.contains(this);
  }

  bool get isOver => isIn([canceled, concluded]);
}
