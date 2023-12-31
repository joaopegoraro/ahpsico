enum AssignmentStatus {
  pending("PENDING"),
  done("DONE"),
  missed("MISSED");

  const AssignmentStatus(this.value);
  final String value;

  factory AssignmentStatus.fromValue(
    String value, {
    AssignmentStatus fallback = AssignmentStatus.pending,
  }) {
    return AssignmentStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }

  bool get isPending {
    return this == pending;
  }

  bool get isDone {
    return this == done;
  }

  bool get isMissed {
    return this == missed;
  }
}
