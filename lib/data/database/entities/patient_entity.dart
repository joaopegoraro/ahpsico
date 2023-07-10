class PatientEntity {
  PatientEntity({
    required this.uuid,
    required this.name,
    required this.phoneNumber,
  });

  final String uuid;
  final String name;
  final String phoneNumber;

  static const String tableName = "patients";
  static const String uuidColumn = "_uuid";
  static const String nameColumn = "name";
  static const String phoneNumberColumn = "phone_number";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $uuidColumn UUID PRIMARY KEY, 
     $nameColumn TEXT, 
     $phoneNumberColumn TEXT)
""";

  PatientEntity copyWith({
    String? uuid,
    String? name,
    String? phoneNumber,
  }) {
    return PatientEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      uuidColumn: uuid,
      nameColumn: name,
      phoneNumberColumn: phoneNumber,
    };
  }

  factory PatientEntity.fromMap(Map<String, dynamic> map) {
    return PatientEntity(
      uuid: map[uuidColumn] as String,
      name: map[nameColumn] as String,
      phoneNumber: map[phoneNumberColumn] as String,
    );
  }

  @override
  String toString() {
    return 'PatientEntity(uuid: $uuid, name: $name, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant PatientEntity other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid && other.name == name && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^ name.hashCode ^ phoneNumber.hashCode;
  }
}
