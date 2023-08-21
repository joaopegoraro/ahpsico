import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/advice.dart';

abstract class AdviceMapper {
  static Advice toAdvice(
    AdviceEntity entity, {
    required UserEntity doctorEntity,
    required List<String> patientIds,
  }) {
    return Advice(
      id: entity.id,
      message: entity.message,
      doctor: UserMapper.toUser(doctorEntity),
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
