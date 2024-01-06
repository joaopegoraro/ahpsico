enum AssignmentStatus {
  pending(0),
  done(1),
  missed(2);

  const AssignmentStatus(this.value);
  final int value;

  factory AssignmentStatus.fromValue(
    int value, {
    AssignmentStatus fallback = AssignmentStatus.pending,
  }) {
    return AssignmentStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }
}
