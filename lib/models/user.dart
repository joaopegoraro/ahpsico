import 'dart:convert';

class User {
  const User({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.isDoctor,
  });

  final String uid;
  final String name;
  final String phoneNumber;
  final bool isDoctor;

  String get firstName => name.split(" ").first;

  User copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    bool? isDoctor,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDoctor: isDoctor ?? this.isDoctor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_uuid': uid,
      'user_name': name,
      'phone_number': phoneNumber,
      'is_doctor': isDoctor,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['user_uuid'] as String,
      name: map['user_name'] as String,
      phoneNumber: map['phone_number'] as String,
      isDoctor: map['is_doctor'] as bool,
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory User.fromJson(String source) {
    return User.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, phoneNumber: $phoneNumber, isDoctor: $isDoctor)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.name == name && other.phoneNumber == phoneNumber && other.isDoctor == isDoctor;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ phoneNumber.hashCode ^ isDoctor.hashCode;
  }
}
