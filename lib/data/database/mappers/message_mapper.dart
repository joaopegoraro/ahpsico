import 'package:ahpsico/data/database/entities/message_entity.dart';
import 'package:ahpsico/models/message.dart';

abstract class MessageMapper {
  static Message toMessage(MessageEntity entity) {
    return Message(
      id: entity.id,
      text: entity.text,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtTimestamp),
    );
  }

  static MessageEntity toEntity(Message message) {
    return MessageEntity(
      id: message.id,
      text: message.text,
      createdAtTimestamp: message.createdAt.millisecondsSinceEpoch,
    );
  }
}
