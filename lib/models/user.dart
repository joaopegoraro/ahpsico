import 'dart:convert';

import 'package:ahpsico/constants/user_role.dart';
import 'package:ahpsico/constants/user_status.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.education,
    required this.occupation,
    required this.role,
    required this.status,
  });

  final int id;
  final String name;
  final String phoneNumber;
  final String address;
  final String education;
  final String occupation;
  final UserRole role;
  final UserStatus status;

  String get firstName => name.split(" ").first;

  User copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? address,
    String? education,
    String? occupation,
    UserRole? role,
    UserStatus? status,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'education': education,
      'occupation': occupation,
      'role': role.value,
      'status': status.value,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      address: map['address'] as String,
      education: map['education'] as String,
      occupation: map['occupation'] as String,
      role: UserRole.fromValue(map['role']),
      status: UserStatus.fromValue(map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, phoneNumber: $phoneNumber, address: $address, education: $education, occupation: $occupation, role: $role, status: $status)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.address == address &&
        other.education == education &&
        other.occupation == occupation &&
        other.role == role &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        address.hashCode ^
        education.hashCode ^
        occupation.hashCode ^
        role.hashCode ^
        status.hashCode;
  }
}
