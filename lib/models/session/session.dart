import 'dart:convert';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/utils/time_utils.dart';
import 'package:intl/intl.dart';

class Session {
  const Session({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.groupIndex,
    required this.status,
    required this.type,
    required this.date,
  });

  final int id;
  final User doctor;
  final User patient;
  final int groupIndex;
  final SessionStatus status;
  final SessionType type;
  final DateTime date;

  String get readableDate {
    return TimeUtils.getReadableDate(date);
  }

  String get dateTime {
    return TimeUtils.getDateAsHours(date);
  }

  Session copyWith({
    int? id,
    User? doctor,
    User? patient,
    int? groupIndex,
    SessionStatus? status,
    SessionType? type,
    DateTime? date,
  }) {
    return Session(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      patient: patient ?? this.patient,
      groupIndex: groupIndex ?? this.groupIndex,
      status: status ?? this.status,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'doctor': doctor.toMap(),
      'patient': patient.toMap(),
      'group_index': groupIndex,
      'status': status.value,
      'type': type.value,
      'date': TimeUtils.formatDateWithOffset(date, AppConstants.datePattern),
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int,
      doctor: User.fromMap(map['doctor'] as Map<String, dynamic>),
      patient: User.fromMap(map['patient'] as Map<String, dynamic>),
      groupIndex: map['group_index'] as int,
      status: SessionStatus.fromValue(map['status']),
      type: SessionType.fromValue(map['type']),
      date: DateFormat(AppConstants.datePattern).parse(map['date']),
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Session.fromJson(String source) {
    return Session.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Session(id: $id, doctor: $doctor, patient: $patient, groupIndex: $groupIndex, status: $status, type: $type, date: $date)';
  }

  @override
  bool operator ==(covariant Session other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.doctor == doctor &&
        other.patient == patient &&
        other.groupIndex == groupIndex &&
        other.status == status &&
        other.type == type &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        doctor.hashCode ^
        patient.hashCode ^
        groupIndex.hashCode ^
        status.hashCode ^
        type.hashCode ^
        date.hashCode;
  }
}
