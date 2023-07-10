import 'dart:convert';

import 'package:flutter/foundation.dart';

class Patient {
  Patient({
    required this.uuid,
    required this.name,
    required this.phoneNumber,
    required this.doctorIds,
  });

  final String uuid;
  final String name;
  final String phoneNumber;
  final List<String> doctorIds;

  Patient copyWith({
    String? uuid,
    String? name,
    String? phoneNumber,
    List<String>? doctorIds,
  }) {
    return Patient(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      doctorIds: doctorIds ?? this.doctorIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'name': name,
      'phone_number': phoneNumber,
      'doctors': doctorIds,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      doctorIds: List<String>.from(map['doctors']),
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Patient.fromJson(String source) {
    return Patient.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Patient(uuid: $uuid, name: $name, phoneNumber: $phoneNumber, doctors: $doctorIds)';
  }

  @override
  bool operator ==(covariant Patient other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        listEquals(other.doctorIds, doctorIds);
  }

  @override
  int get hashCode {
    return uuid.hashCode ^ name.hashCode ^ phoneNumber.hashCode ^ doctorIds.hashCode;
  }
}
