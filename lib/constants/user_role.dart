import 'package:collection/collection.dart';

enum UserRole {
  patient("PATIENT"),
  doctor("DOCTOR");

  const UserRole(this.value);

  final String value;

  static UserRole fromValue(String value) {
    final role = UserRole.values.firstWhereOrNull((element) {
      return element.value == value;
    });
    return role ?? UserRole.patient;
  }

  bool get isPatient {
    return this == patient;
  }

  bool get isDoctor {
    return this == doctor;
  }
}
