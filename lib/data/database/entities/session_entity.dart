class SessionEntity {
  SessionEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.groupIndex,
    required this.status,
    required this.type,
    required this.dateInMillisecondsSinceEpoch,
  });

  final int id;
  final String doctorId;
  final String patientId;
  final int groupIndex;
  final int status;
  final int type;
  final int dateInMillisecondsSinceEpoch;

  static const tableName = "sessions";
  static const idColumn = "_id";
  static const doctorIdColumn = "doctor_id";
  static const patientIdColumn = "patient_id";
  static const groupIndexColumn = "group_index";
  static const statusColumn = "status";
  static const typeColumn = "type";
  static const dateColumn = "date";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $doctorIdColumn TEXT,
     $patientIdColumn TEXT,
     $groupIndexColumn INTEGER,
     $statusColumn INTEGER,
     $typeColumn INTEGER,
     $dateColumn INTEGER)
""";

  SessionEntity copyWith({
    int? id,
    String? doctorId,
    String? patientId,
    int? groupId,
    int? groupIndex,
    int? status,
    int? type,
    int? dateInMillisecondsSinceEpoch,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      groupIndex: groupIndex ?? this.groupIndex,
      status: status ?? this.status,
      type: type ?? this.type,
      dateInMillisecondsSinceEpoch:
          dateInMillisecondsSinceEpoch ?? this.dateInMillisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      doctorIdColumn: doctorId,
      patientIdColumn: patientId,
      groupIndexColumn: groupIndex,
      statusColumn: status,
      typeColumn: type,
      dateColumn: dateInMillisecondsSinceEpoch,
    };
  }

  factory SessionEntity.fromMap(Map<String, dynamic> map) {
    return SessionEntity(
      id: map[idColumn] as int,
      doctorId: map[doctorIdColumn] as String,
      patientId: map[patientIdColumn] as String,
      groupIndex: map[groupIndexColumn] as int,
      status: map[statusColumn] as int,
      type: map[typeColumn] as int,
      dateInMillisecondsSinceEpoch: map[dateColumn] as int,
    );
  }

  @override
  String toString() {
    return 'SessionEntity(id: $id, doctorId: $doctorId, patientId: $patientId, groupIndex: $groupIndex, status: $status, type: $type, date: $dateInMillisecondsSinceEpoch)';
  }

  @override
  bool operator ==(covariant SessionEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.doctorId == doctorId &&
        other.patientId == patientId &&
        other.groupIndex == groupIndex &&
        other.status == status &&
        other.type == type &&
        other.dateInMillisecondsSinceEpoch == dateInMillisecondsSinceEpoch;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        doctorId.hashCode ^
        patientId.hashCode ^
        groupIndex.hashCode ^
        status.hashCode ^
        type.hashCode ^
        dateInMillisecondsSinceEpoch.hashCode;
  }
}
