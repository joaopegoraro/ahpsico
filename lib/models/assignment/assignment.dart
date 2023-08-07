import 'dart:convert';

import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';

class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.doctor,
    required this.patientId,
    required this.status,
    required this.deliverySession,
  });

  final int id;
  final String title;
  final String description;
  final User doctor;
  final String patientId;
  final AssignmentStatus status;
  final Session deliverySession;

  Assignment copyWith({
    int? id,
    String? title,
    String? description,
    User? doctor,
    String? patientId,
    AssignmentStatus? status,
    Session? deliverySession,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      doctor: doctor ?? this.doctor,
      patientId: patientId ?? this.patientId,
      status: status ?? this.status,
      deliverySession: deliverySession ?? this.deliverySession,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'doctor': doctor.toMap(),
      'patient': patientId,
      'status': status.value,
      'delivery_session': deliverySession.toMap(),
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      doctor: User.fromMap(map['doctor'] as Map<String, dynamic>),
      patientId: map['patient'] as String,
      status: AssignmentStatus.fromValue(map['status']),
      deliverySession: Session.fromMap(map['delivery_session'] as Map<String, dynamic>),
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Assignment.fromJson(String source) {
    return Assignment.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, description: $description, doctor: $doctor, patientId: $patientId, status: $status, deliverySession: $deliverySession)';
  }

  @override
  bool operator ==(covariant Assignment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.doctor == doctor &&
        other.patientId == patientId &&
        other.status == status &&
        other.deliverySession == deliverySession;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        doctor.hashCode ^
        patientId.hashCode ^
        status.hashCode ^
        deliverySession.hashCode;
  }
}
