import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/models/user.dart';

abstract class UserMapper {
  static User toUser(UserEntity entity) {
    return User(
      uuid: entity.uuid,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      description: entity.description,
      crp: entity.crp,
      pixKey: entity.pixKey,
      paymentDetails: entity.paymentDetails,
      role: UserRole.fromValue(entity.role),
    );
  }

  static UserEntity toEntity(User user) {
    return UserEntity(
        uuid: user.uuid,
        name: user.name,
        phoneNumber: user.phoneNumber,
        description: user.description,
        crp: user.crp,
        pixKey: user.pixKey,
        paymentDetails: user.paymentDetails,
        role: user.role.value);
  }
}
