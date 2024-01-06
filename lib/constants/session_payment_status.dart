import 'package:collection/collection.dart';

enum SessionPaymentStatus {
  notPayed("NOT_PAYED"),
  payed("PAYED");

  const SessionPaymentStatus(this.value);
  final String value;

  static SessionPaymentStatus? fromValue(String? value) {
    return SessionPaymentStatus.values.firstWhereOrNull(
      (element) => element.value == value,
    );
  }

  bool get isNotPayed {
    return this == notPayed;
  }

  bool get isPayed {
    return this == payed;
  }
}
