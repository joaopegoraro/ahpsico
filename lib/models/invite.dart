import 'dart:convert';

import 'package:ahpsico/models/doctor.dart';

class Invite {
  const Invite({
    required this.id,
    required this.doctor,
    required this.patientId,
    required this.phoneNumber,
  });

  final int id;
  final Doctor doctor;
  final String patientId;
  final String phoneNumber;

  Invite copyWith({
    int? id,
    Doctor? doctor,
    String? patientId,
    String? phoneNumber,
  }) {
    return Invite(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      patientId: patientId ?? this.patientId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'doctor': doctor.toMap(),
      'patient': patientId,
      'phone_number': phoneNumber,
    };
  }

  factory Invite.fromMap(Map<String, dynamic> map) {
    return Invite(
      id: map['id'] as int,
      doctor: Doctor.fromMap(map['doctor'] as Map<String, dynamic>),
      patientId: map['patient'] as String,
      phoneNumber: map['phone_number'] as String,
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Invite.fromJson(String source) {
    return Invite.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Invite(id: $id, doctor: $doctor, patientId: $patientId, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant Invite other) {
    if (identical(this, other)) return true;

    return other.id == id && other.doctor == doctor && other.patientId == patientId && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^ doctor.hashCode ^ patientId.hashCode ^ phoneNumber.hashCode;
  }
}
