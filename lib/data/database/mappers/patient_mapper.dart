import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/models/patient.dart';

class PatientMapper {
  static Patient toPatient(PatientEntity entity) {
    return Patient(
      uuid: entity.uuid,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
    );
  }

  static PatientEntity toEntity(Patient patient) {
    return PatientEntity(
      uuid: patient.uuid,
      name: patient.name,
      phoneNumber: patient.phoneNumber,
    );
  }
}
