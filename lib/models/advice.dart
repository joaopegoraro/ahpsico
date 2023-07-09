// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:ahpsico/models/doctor.dart';

class Advice {
  Advice({
    required this.message,
    required this.doctor,
    required this.patientIds,
  });

  final String message;
  final Doctor doctor;
  final List<String> patientIds;

  Advice copyWith({
    String? message,
    Doctor? doctor,
    List<String>? patientIds,
  }) {
    return Advice(
      message: message ?? this.message,
      doctor: doctor ?? this.doctor,
      patientIds: patientIds ?? this.patientIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'doctor': doctor.toMap(),
      'patients': patientIds,
    };
  }

  factory Advice.fromMap(Map<String, dynamic> map) {
    return Advice(
      message: map['message'] as String,
      doctor: Doctor.fromMap(map['doctor'] as Map<String, dynamic>),
      patientIds: List<String>.from((map['patients'] as List<String>)),
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
    return 'Advice(message: $message, doctor: $doctor, patientIds: $patientIds)';
  }

  @override
  bool operator ==(covariant Advice other) {
    if (identical(this, other)) return true;

    return other.message == message && other.doctor == doctor && listEquals(other.patientIds, patientIds);
  }

  @override
  int get hashCode {
    return message.hashCode ^ doctor.hashCode ^ patientIds.hashCode;
  }
}
