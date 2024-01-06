import 'package:ahpsico/constants/user_role.dart';
import 'package:ahpsico/constants/user_status.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/models/user.dart';

abstract class UserMapper {
  static User toUser(UserEntity entity) {
    return User(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      education: entity.education,
      occupation: entity.occupation,
      role: UserRole.fromValue(entity.role),
      status: UserStatus.fromValue(entity.status),
    );
  }

  static UserEntity toEntity(User user) {
    return UserEntity(
      id: user.id,
      name: user.name,
      phoneNumber: user.phoneNumber,
      address: user.address,
      education: user.education,
      occupation: user.occupation,
      role: user.role.value,
      status: user.status.value,
    );
  }
}
