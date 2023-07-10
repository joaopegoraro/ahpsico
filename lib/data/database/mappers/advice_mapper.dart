import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/models/advice.dart';

class AdviceMapper {
  static Advice toAdvice(
    AdviceEntity entity, {
    required DoctorEntity doctorEntity,
    required List<String> patientIds,
  }) {
    return Advice(
      id: entity.id,
      message: entity.message,
      doctor: DoctorMapper.toDoctor(doctorEntity),
      patientIds: patientIds,
    );
  }

  static AdviceEntity toEntity(Advice advice) {
    return AdviceEntity(
      id: advice.id,
      message: advice.message,
      doctorId: advice.doctor.uuid,
    );
  }
}
