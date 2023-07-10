import 'dart:convert';

import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';

class Session {
  Session({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.groupId,
    required this.groupIndex,
    required this.status,
    required this.type,
    required this.date,
  });

  final int id;
  final Doctor doctor;
  final Patient patient;
  final int groupId;
  final int groupIndex;
  final SessionStatus status;
  final SessionType type;
  final String date;

  Session copyWith({
    int? id,
    Doctor? doctor,
    Patient? patient,
    int? groupId,
    int? groupIndex,
    SessionStatus? status,
    SessionType? type,
    String? date,
  }) {
    return Session(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      patient: patient ?? this.patient,
      groupId: groupId ?? this.groupId,
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
      'group_id': groupId,
      'group_index': groupIndex,
      'status': status.value,
      'type': type.value,
      'date': date,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int,
      doctor: Doctor.fromMap(map['doctor'] as Map<String, dynamic>),
      patient: Patient.fromMap(map['patient'] as Map<String, dynamic>),
      groupId: map['group_id'] as int,
      groupIndex: map['group_index'] as int,
      status: SessionStatus.fromValue(map['status']),
      type: SessionType.fromValue(map['type']),
      date: map['date'] as String,
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
    return 'Session(id: $id, doctor: $doctor, patient: $patient, groupId: $groupId, groupIndex: $groupIndex, status: $status, type: $type, date: $date)';
  }

  @override
  bool operator ==(covariant Session other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.doctor == doctor &&
        other.patient == patient &&
        other.groupId == groupId &&
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
        groupId.hashCode ^
        groupIndex.hashCode ^
        status.hashCode ^
        type.hashCode ^
        date.hashCode;
  }
}
