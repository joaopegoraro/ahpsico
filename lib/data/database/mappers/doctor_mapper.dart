import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/models/doctor.dart';

abstract class DoctorMapper {
  static Doctor toDoctor(DoctorEntity entity) {
    return Doctor(
      uuid: entity.uuid,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      description: entity.description,
      crp: entity.crp,
      pixKey: entity.pixKey,
      paymentDetails: entity.paymentDetails,
    );
  }

  static DoctorEntity toEntity(Doctor doctor) {
    return DoctorEntity(
      uuid: doctor.uuid,
      name: doctor.name,
      phoneNumber: doctor.phoneNumber,
      description: doctor.description,
      crp: doctor.crp,
      pixKey: doctor.pixKey,
      paymentDetails: doctor.paymentDetails,
    );
  }
}
