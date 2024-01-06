enum UserRole {
  patient("PATIENT"),
  doctor("DOCTOR");

  const UserRole(this.value);
  final String value;

  factory UserRole.fromValue(
    String value, {
    UserRole fallback = UserRole.patient,
  }) {
    return UserRole.values.firstWhere(
      (element) => element.value == value,
      orElse: () => fallback,
    );
  }

  bool get isPatient {
    return this == patient;
  }

  bool get isDoctor {
    return this == doctor;
  }
}
