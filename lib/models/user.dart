// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

enum UserRole {
  patient(1),
  doctor(2);

  const UserRole(this.value);

  final int value;

  static UserRole fromValue(int value) {
    return UserRole.values.firstWhereOrNull((element) {
          return element.value == value;
        }) ??
        UserRole.patient;
  }
}

class User {
  const User({
    required this.uuid,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.crp,
    required this.pixKey,
    required this.paymentDetails,
    required this.role,
  });

  final String uuid;
  final String name;
  final String phoneNumber;
  final String description;
  final String crp;
  final String pixKey;
  final String paymentDetails;
  final UserRole role;

  String get firstName => name.split(" ").first;

  User copyWith({
    String? uuid,
    String? name,
    String? phoneNumber,
    String? description,
    String? crp,
    String? pixKey,
    String? paymentDetails,
    UserRole? role,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      crp: crp ?? this.crp,
      pixKey: pixKey ?? this.pixKey,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'name': name,
      'phoneNumber': phoneNumber,
      'description': description,
      'crp': crp,
      'pixKey': pixKey,
      'paymentDetails': paymentDetails,
      'role': role.value,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      description: map['description'] as String,
      crp: map['crp'] as String,
      pixKey: map['pixKey'] as String,
      paymentDetails: map['paymentDetails'] as String,
      role: UserRole.fromValue(map['role']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(uuid: $uuid, name: $name, phoneNumber: $phoneNumber, description: $description, crp: $crp, pixKey: $pixKey, paymentDetails: $paymentDetails, role: $role)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.description == description &&
        other.crp == crp &&
        other.pixKey == pixKey &&
        other.paymentDetails == paymentDetails &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        description.hashCode ^
        crp.hashCode ^
        pixKey.hashCode ^
        paymentDetails.hashCode ^
        role.hashCode;
  }
}
