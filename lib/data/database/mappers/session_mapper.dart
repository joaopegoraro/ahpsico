import 'package:ahpsico/constants/session_payment_status.dart';
import 'package:ahpsico/constants/session_payment_type.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/constants/session_type.dart';
import 'package:ahpsico/constants/user_role.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/session.dart';

abstract class SessionMapper {
  static Session toSession(
    SessionEntity entity, {
    required UserEntity userEntity,
  }) {
    return Session(
      id: entity.id,
      user: UserMapper.toUser(userEntity),
      date: DateTime.fromMillisecondsSinceEpoch(entity.dateTimestamp),
      groupIndex: entity.groupIndex,
      status: SessionStatus.fromValue(entity.status),
      type: SessionType.fromValue(entity.type),
      paymentStatus: SessionPaymentStatus.fromValue(entity.paymentStatus),
      paymentType: SessionPaymentType.fromValue(entity.paymentType),
      updatedBy: UserRole.fromValue(entity.updatedBy),
      updateMessage: entity.updateMessage,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtTimestamp),
    );
  }

  static SessionEntity toEntity(Session session) {
    return SessionEntity(
      id: session.id,
      userId: session.user.id,
      dateTimestamp: session.date.millisecondsSinceEpoch,
      groupIndex: session.groupIndex,
      status: session.status.value,
      type: session.type.value,
      paymentStatus: session.paymentStatus?.value,
      paymentType: session.paymentType.value,
      updatedBy: session.updatedBy.value,
      updateMessage: session.updateMessage,
      updatedAtTimestamp: session.updatedAt.millisecondsSinceEpoch,
    );
  }
}
