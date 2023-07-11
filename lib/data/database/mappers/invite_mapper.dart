import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/models/invite.dart';

abstract class InviteMapper {
  static Invite toInvite(
    InviteEntity entity, {
    required DoctorEntity doctorEntity,
  }) {
    return Invite(
      id: entity.id,
      doctor: DoctorMapper.toDoctor(doctorEntity),
      patientId: entity.patientId,
      phoneNumber: entity.phoneNumber,
    );
  }

  static InviteEntity toEntity(Invite invite) {
    return InviteEntity(
      id: invite.id,
      doctorId: invite.doctor.uuid,
      patientId: invite.patientId,
      phoneNumber: invite.phoneNumber,
    );
  }
}
