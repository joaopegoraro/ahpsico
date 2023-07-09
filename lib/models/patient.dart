// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Patient {
  Patient({
    required this.uuid,
    required this.name,
    required this.phoneNumber,
  });

  final String uuid;
  final String name;
  final String phoneNumber;

  Patient copyWith({
    String? uuid,
    String? name,
    String? phoneNumber,
  }) {
    return Patient(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'name': name,
      'phone_number': phoneNumber,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
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
    return 'Patient(uuid: $uuid, name: $name, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant Patient other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid && other.name == name && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^ name.hashCode ^ phoneNumber.hashCode;
  }
}
