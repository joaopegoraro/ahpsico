import 'package:ahpsico/constants/assignment_status.dart';
import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/models/assignment.dart';

abstract class AssignmentMapper {
  static Assignment toAssignment(
    AssignmentEntity entity, {
    required UserEntity userEntity,
    required SessionEntity sessionEntity,
  }) {
    return Assignment(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      userId: entity.userId,
      status: AssignmentStatus.fromValue(entity.status),
      session: SessionMapper.toSession(
        sessionEntity,
        userEntity: userEntity,
      ),
    );
  }

  static AssignmentEntity toEntity(Assignment assignment) {
    return AssignmentEntity(
      id: assignment.id,
      title: assignment.title,
      description: assignment.description,
      userId: assignment.userId,
      status: assignment.status.value,
      sessionId: assignment.session.id,
    );
  }
}
