import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';

abstract class AssignmentMapper {
  static Assignment toAssignment(
    AssignmentEntity entity, {
    required DoctorEntity doctorEntity,
    required SessionEntity sessionEntity,
    required PatientEntity patientEntity,
  }) {
    return Assignment(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      patientId: entity.patientId,
      doctor: DoctorMapper.toDoctor(doctorEntity),
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
