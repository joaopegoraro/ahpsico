import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';

abstract class AssignmentMapper {
  static Assignment toAssignment(
    AssignmentEntity entity, {
    required UserEntity doctorEntity,
    required SessionEntity sessionEntity,
    required UserEntity patientEntity,
  }) {
    return Assignment(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      patientId: entity.patientId,
      doctor: UserMapper.toUser(doctorEntity),
      status: AssignmentStatus.fromValue(entity.status),
      deliverySession: SessionMapper.toSession(
        sessionEntity,
        doctorEntity: doctorEntity,
        patientEntity: patientEntity,
      ),
    );
  }

  static AssignmentEntity toEntity(Assignment assignment) {
    return AssignmentEntity(
      id: assignment.id,
      title: assignment.title,
      description: assignment.description,
      doctorId: assignment.doctor.uuid,
      patientId: assignment.patientId,
      status: assignment.status.value,
      deliverySessionId: assignment.deliverySession.id,
    );
  }
}
