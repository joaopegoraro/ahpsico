import 'dart:convert';

import 'package:ahpsico/constants/session_payment_status.dart';
import 'package:ahpsico/constants/session_payment_type.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/constants/session_type.dart';
import 'package:ahpsico/constants/user_role.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/utils/time_utils.dart';

class Session {
  const Session({
    required this.id,
    required this.user,
    required this.date,
    required this.type,
    required this.groupIndex,
    required this.status,
    required this.paymentStatus,
    required this.paymentType,
    required this.updatedBy,
    required this.updateMessage,
    required this.updatedAt,
  });

  final int id;
  final User user;
  final DateTime date;
  final SessionType type;
  final int groupIndex;
  final SessionStatus status;
  final SessionPaymentStatus? paymentStatus;
  final SessionPaymentType paymentType;
  final UserRole updatedBy;
  final String updateMessage;
  final DateTime updatedAt;

  String get readableDate {
    return TimeUtils.getReadableDate(date);
  }

  String get dateTime {
    return TimeUtils.getDateAsHours(date);
  }

  Session copyWith({
    int? id,
    User? user,
    DateTime? date,
    SessionType? type,
    int? groupIndex,
    SessionStatus? status,
    SessionPaymentStatus? paymentStatus,
    SessionPaymentType? paymentType,
    UserRole? updatedBy,
    String? updateMessage,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      user: user ?? this.user,
      date: date ?? this.date,
      type: type ?? this.type,
      groupIndex: groupIndex ?? this.groupIndex,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentType: paymentType ?? this.paymentType,
      updatedBy: updatedBy ?? this.updatedBy,
      updateMessage: updateMessage ?? this.updateMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user': user.toMap(),
      'date': date.millisecondsSinceEpoch,
      'type': type.value,
      'groupIndex': groupIndex,
      'status': status.value,
      'paymentStatus': paymentStatus?.value,
      'paymentType': paymentType.value,
      'updatedBy': updatedBy.value,
      'updateMessage': updateMessage,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int,
      user: User.fromMap(map['user'] as Map<String, dynamic>),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      type: SessionType.fromValue(map['type']),
      groupIndex: map['groupIndex'] as int,
      status: SessionStatus.fromValue(map['status']),
      paymentStatus: SessionPaymentStatus.fromValue(map['paymentStatus']),
      paymentType: SessionPaymentType.fromValue(map['paymentType']),
      updatedBy: UserRole.fromValue(map['updatedBy']),
      updateMessage: map['updateMessage'] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Session.fromJson(String source) =>
      Session.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Session(id: $id, user: $user, date: $date, type: $type, groupIndex: $groupIndex, status: $status, paymentStatus: $paymentStatus, paymentType: $paymentType, updatedBy: $updatedBy, updateMessage: $updateMessage, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Session other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.date == date &&
        other.type == type &&
        other.groupIndex == groupIndex &&
        other.status == status &&
        other.paymentStatus == paymentStatus &&
        other.paymentType == paymentType &&
        other.updatedBy == updatedBy &&
        other.updateMessage == updateMessage &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        date.hashCode ^
        type.hashCode ^
        groupIndex.hashCode ^
        status.hashCode ^
        paymentStatus.hashCode ^
        paymentType.hashCode ^
        updatedBy.hashCode ^
        updateMessage.hashCode ^
        updatedAt.hashCode;
  }
}
