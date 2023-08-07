import 'dart:convert';

import 'package:ahpsico/models/user.dart';
import 'package:flutter/foundation.dart';

class Advice {
  const Advice({
    required this.id,
    required this.message,
    required this.doctor,
    required this.patientIds,
  });

  final int id;
  final String message;
  final User doctor;
  final List<String> patientIds;

  Advice copyWith({
    int? id,
    String? message,
    User? doctor,
    List<String>? patientIds,
  }) {
    return Advice(
      id: id ?? this.id,
      message: message ?? this.message,
      doctor: doctor ?? this.doctor,
      patientIds: patientIds ?? this.patientIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
      'doctor': doctor.toMap(),
      'patients': patientIds,
    };
  }

  factory Advice.fromMap(Map<String, dynamic> map) {
    return Advice(
      id: map['id'] as int,
      message: map['message'] as String,
      doctor: User.fromMap(map['doctor'] as Map<String, dynamic>),
      patientIds: List<String>.from((map['patients'])),
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Advice.fromJson(String source) {
    return Advice.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Advice(id: $id, message: $message, doctor: $doctor, patientIds: $patientIds)';
  }

  @override
  bool operator ==(covariant Advice other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.message == message &&
        other.doctor == doctor &&
        listEquals(other.patientIds, patientIds);
  }

  @override
  int get hashCode {
    return id.hashCode ^ message.hashCode ^ doctor.hashCode ^ patientIds.hashCode;
  }
}
