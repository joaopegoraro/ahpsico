import 'package:collection/collection.dart';

enum UserStatus {
  notConfirmed("NOT_CONFIRMED"),
  confirmed("CONFIRMED");

  const UserStatus(this.value);

  final String value;

  static UserStatus fromValue(String value) {
    final role = UserStatus.values.firstWhereOrNull((element) {
      return element.value == value;
    });
    return role ?? UserStatus.notConfirmed;
  }

  bool get isConfirmed {
    return this == confirmed;
  }

  bool get isNotConfirmed {
    return this == notConfirmed;
  }
}
