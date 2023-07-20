import 'dart:convert';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/utils/time_utils.dart';
import 'package:intl/intl.dart';

class Schedule {
  const Schedule({
    required this.id,
    required this.doctorUuid,
    required this.date,
    required this.isSession,
  });

  final int id;
  final String doctorUuid;
  final DateTime date;
  final bool isSession;

  Schedule copyWith({
    int? id,
    String? doctorUuid,
    DateTime? date,
    bool? isSession,
  }) {
    return Schedule(
      id: id ?? this.id,
      doctorUuid: doctorUuid ?? this.doctorUuid,
      date: date ?? this.date,
      isSession: isSession ?? this.isSession,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'doctor': doctorUuid,
      'date': TimeUtils.formatDateWithOffset(date, AppConstants.datePattern),
      'is_session': isSession,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
        id: map['id'] as int,
        doctorUuid: map['doctor'],
        date: DateFormat(AppConstants.datePattern).parse(map['date']),
        isSession: map['is_session']);
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Schedule.fromJson(String source) {
    return Schedule.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Schedule(id: $id, doctorUuid: $doctorUuid, date: $date, isSession: $isSession)';
  }

  @override
  bool operator ==(covariant Schedule other) {
    if (identical(this, other)) return true;

    return other.id == id && other.doctorUuid == doctorUuid && other.date == date && other.isSession == isSession;
  }

  @override
  int get hashCode {
    return id.hashCode ^ doctorUuid.hashCode ^ date.hashCode ^ isSession.hashCode;
  }
}
