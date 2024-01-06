enum UserStatus {
  notConfirmed("NOT_CONFIRMED"),
  confirmed("CONFIRMED");

  const UserStatus(this.value);

  final String value;

  factory UserStatus.fromValue(
    String value, {
    UserStatus fallback = UserStatus.notConfirmed,
  }) {
    return UserStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }

  bool get isConfirmed {
    return this == confirmed;
  }

  bool get isNotConfirmed {
    return this == notConfirmed;
  }
}
