import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/invite.dart';

abstract class InviteMapper {
  static Invite toInvite(
    InviteEntity entity, {
    required UserEntity doctorEntity,
  }) {
    return Invite(
      id: entity.id,
      doctor: UserMapper.toUser(doctorEntity),
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
