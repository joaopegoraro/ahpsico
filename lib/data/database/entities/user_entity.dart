class UserEntity {
  UserEntity({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.isDoctor,
  });

  final String uid;
  final String name;
  final String phoneNumber;
  final bool isDoctor;

  static const String tableName = "users";
  static const String uidColumn = "_uid";
  static const String nameColumn = "name";
  static const String phoneNumberColumn = "phone_number";
  static const String isDoctorColumn = "is_doctor";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $uidColumn UUID PRIMARY KEY, 
     $nameColumn TEXT, 
     $phoneNumberColumn TEXT,
     $isDoctorColumn TINYINT(4))
""";

  UserEntity copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    bool? isDoctor,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDoctor: isDoctor ?? this.isDoctor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      uidColumn: uid,
      nameColumn: name,
      phoneNumberColumn: phoneNumber,
      isDoctorColumn: isDoctor ? 1 : 0,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map[uidColumn] as String,
      name: map[nameColumn] as String,
      phoneNumber: map[phoneNumberColumn] as String,
      isDoctor: map[isDoctorColumn] as int != 0,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, name: $name, phoneNumber: $phoneNumber, isDoctor: $isDoctor)';
  }

  @override
  bool operator ==(covariant UserEntity other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.name == name && other.phoneNumber == phoneNumber && other.isDoctor == isDoctor;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ phoneNumber.hashCode ^ isDoctor.hashCode;
  }
}
