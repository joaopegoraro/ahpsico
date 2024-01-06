import "dart:convert";

class UserEntity {
  UserEntity({
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
  final String role;
  final String status;

  static const String tableName = "users";
  static const String idColumn = "_id";
  static const String nameColumn = "name";
  static const String phoneNumberColumn = "phone_number";
  static const String addressColumn = "address";
  static const String educationColumn = "education";
  static const String occupationColumn = "occupation";
  static const String roleColumn = "role";
  static const String statusColumn = "status";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn LONG PRIMARY KEY, 
     $nameColumn TEXT, 
     $phoneNumberColumn TEXT,
     $addressColumn TEXT,
     $educationColumn TEXT,
     $occupationColumn TEXT,
     $roleColumn TEXT,
     $statusColumn STATUS)
""";

  UserEntity copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? address,
    String? education,
    String? occupation,
    String? role,
    String? status,
  }) {
    return UserEntity(
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
      idColumn: id,
      nameColumn: name,
      phoneNumberColumn: phoneNumber,
      addressColumn: address,
      educationColumn: education,
      occupationColumn: occupation,
      roleColumn: role,
      statusColumn: status,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map[idColumn] as int,
      name: map[nameColumn] as String,
      phoneNumber: map[phoneNumberColumn] as String,
      address: map[addressColumn] as String,
      education: map[educationColumn] as String,
      occupation: map[occupationColumn] as String,
      role: map[roleColumn] as String,
      status: map[statusColumn] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, phoneNumber: $phoneNumber, address: $address, education: $education, occupation: $occupation, role: $role, status: $status)';
  }

  @override
  bool operator ==(covariant UserEntity other) {
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
