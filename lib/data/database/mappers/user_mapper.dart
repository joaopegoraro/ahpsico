import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/models/user.dart';

abstract class UserMapper {
  static User toUser(UserEntity entity) {
    return User(
      uid: entity.uid,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      isDoctor: entity.isDoctor,
    );
  }

  static UserEntity toEntity(User user) {
    return UserEntity(
      uid: user.uid,
      name: user.name,
      phoneNumber: user.phoneNumber,
      isDoctor: user.isDoctor,
    );
  }
}
