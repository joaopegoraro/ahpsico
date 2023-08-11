import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_payment_status.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';

abstract class SessionMapper {
  static Session toSession(
    SessionEntity entity, {
    required UserEntity doctorEntity,
    required UserEntity patientEntity,
  }) {
    return Session(
      id: entity.id,
      doctor: UserMapper.toUser(doctorEntity),
      patient: UserMapper.toUser(patientEntity),
      groupIndex: entity.groupIndex,
      status: SessionStatus.fromValue(entity.status),
      paymentStatus: SessionPaymentStatus.fromValue(entity.status),
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
      paymentStatus: session.paymentStatus.value,
      type: session.type.value,
      dateInMillisecondsSinceEpoch: session.date.millisecondsSinceEpoch,
    );
  }
}
