// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Doctor {
  const Doctor({
    required this.uuid,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.crp,
    required this.pixKey,
    required this.paymentDetails,
  });

  final String uuid;
  final String name;
  final String phoneNumber;
  final String description;
  final String crp;
  final String pixKey;
  final String paymentDetails;

  Doctor copyWith({
    String? uuid,
    String? name,
    String? phoneNumber,
    String? description,
    String? crp,
    String? pixKey,
    String? paymentDetails,
  }) {
    return Doctor(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      crp: crp ?? this.crp,
      pixKey: pixKey ?? this.pixKey,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'name': name,
      'phone_number': phoneNumber,
      'description': description,
      'crp': crp,
      'pix_key': pixKey,
      'payment_details': paymentDetails,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      description: map['description'] as String,
      crp: map['crp'] as String,
      pixKey: map['pix_key'] as String,
      paymentDetails: map['payment_details'] as String,
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory Doctor.fromJson(String source) {
    return Doctor.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Doctor(uuid: $uuid, name: $name, phoneNumber: $phoneNumber, description: $description, crp: $crp, pixKey: $pixKey, paymentDetails: $paymentDetails)';
  }

  @override
  bool operator ==(covariant Doctor other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.description == description &&
        other.crp == crp &&
        other.pixKey == pixKey &&
        other.paymentDetails == paymentDetails;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        description.hashCode ^
        crp.hashCode ^
        pixKey.hashCode ^
        paymentDetails.hashCode;
  }
}
