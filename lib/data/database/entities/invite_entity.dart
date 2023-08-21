class InviteEntity {
  InviteEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.phoneNumber,
  });

  final int id;
  final String doctorId;
  final String patientId;
  final String phoneNumber;

  static const tableName = "invites";
  static const idColumn = "_id";
  static const doctorIdColumn = "doctor_id";
  static const patientIdColumn = "patient_id";
  static const phoneNumberColumn = "phone_number";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $doctorIdColumn TEXT,
     $patientIdColumn TEXT,
     $phoneNumberColumn TEXT)
""";

  InviteEntity copyWith({
    int? id,
    String? doctorId,
    String? patientId,
    String? phoneNumber,
  }) {
    return InviteEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      doctorIdColumn: doctorId,
      patientIdColumn: patientId,
      phoneNumberColumn: phoneNumber,
    };
  }

  factory InviteEntity.fromMap(Map<String, dynamic> map) {
    return InviteEntity(
      id: map[idColumn] as int,
      doctorId: map[doctorIdColumn] as String,
      patientId: map[patientIdColumn] as String,
      phoneNumber: map[phoneNumberColumn] as String,
    );
  }

  @override
  String toString() {
    return 'InviteEntity(id: $id, doctorId: $doctorId, patientId: $patientId, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant InviteEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.doctorId == doctorId &&
        other.patientId == patientId &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^ doctorId.hashCode ^ patientId.hashCode ^ phoneNumber.hashCode;
  }
}
