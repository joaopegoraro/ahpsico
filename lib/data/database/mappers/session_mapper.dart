import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';

abstract class SessionMapper {
  static Session toSession(
    SessionEntity entity, {
    required DoctorEntity doctorEntity,
    required PatientEntity patientEntity,
  }) {
    return Session(
      id: entity.id,
      doctor: DoctorMapper.toDoctor(doctorEntity),
      patient: PatientMapper.toPatient(patientEntity),
      groupIndex: entity.groupIndex,
      status: SessionStatus.fromValue(entity.status),
      type: SessionType.fromValue(entity.type),
      date: DateTime.fromMillisecondsSinceEpoch(entity.dateInMillisecondsSinceEpoch),
    );
  }

  static SessionEntity toEntity(Session session) {
    return SessionEntity(
      id: session.id,
      doctorId: session.doctor.uuid,
      patientId: session.patient.uuid,
      groupIndex: session.groupIndex,
      status: session.status.value,
      type: session.type.value,
      dateInMillisecondsSinceEpoch: session.date.millisecondsSinceEpoch,
    );
  }
}
