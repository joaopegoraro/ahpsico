import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';

class SessionEntity {
  SessionEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.groupId,
    required this.groupIndex,
    required this.status,
    required this.type,
    required this.date,
  });

  final int id;
  final String doctorId;
  final String patientId;
  final int groupId;
  final int groupIndex;
  final String status;
  final String type;
  final String date;

  static const tableName = "sessions";
  static const idColumn = "_id";
  static const doctorIdColumn = "doctor_id";
  static const patientIdColumn = "patient_id";
  static const groupIdColumn = "group_id";
  static const groupIndexColumn = "group_index";
  static const statusColumn = "status";
  static const typeColumn = "type";
  static const dateColumn = "date";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $doctorIdColumn TEXT,
     $patientIdColumn TEXT,
     $groupIdColumn INTEGER,
     $groupIndexColumn INTEGER,
     $statusColumn TEXT,
     $typeColumn TEXT,
     $dateColumn TEXT,
     FOREIGN KEY ($doctorIdColumn) REFERENCES Type (${DoctorEntity.uuidColumn}) ON DELETE CASCADE, 
     FOREIGN KEY ($patientIdColumn) REFERENCES Type (${PatientEntity.uuidColumn}) ON DELETE CASCADE)
""";

  SessionEntity copyWith({
    int? id,
    String? doctorId,
    String? patientId,
    int? groupId,
    int? groupIndex,
    String? status,
    String? type,
    String? date,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      groupId: groupId ?? this.groupId,
      groupIndex: groupIndex ?? this.groupIndex,
      status: status ?? this.status,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      doctorId: doctorId,
      patientId: patientId,
      groupIdColumn: groupId,
      groupIndexColumn: groupIndex,
      statusColumn: status,
      typeColumn: type,
      dateColumn: date,
    };
  }

  factory SessionEntity.fromMap(Map<String, dynamic> map) {
    return SessionEntity(
      id: map[idColumn] as int,
      doctorId: map[doctorIdColumn] as String,
      patientId: map[patientIdColumn] as String,
      groupId: map[groupIdColumn] as int,
      groupIndex: map[groupIndexColumn] as int,
      status: map[statusColumn] as String,
      type: map[typeColumn] as String,
      date: map[dateColumn] as String,
    );
  }

  @override
  String toString() {
    return 'SessionEntity(id: $id, doctorId: $doctorId, patientId: $patientId, groupId: $groupId, groupIndex: $groupIndex, status: $status, type: $type, date: $date)';
  }

  @override
  bool operator ==(covariant SessionEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.doctorId == doctorId &&
        other.patientId == patientId &&
        other.groupId == groupId &&
        other.groupIndex == groupIndex &&
        other.status == status &&
        other.type == type &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        doctorId.hashCode ^
        patientId.hashCode ^
        groupId.hashCode ^
        groupIndex.hashCode ^
        status.hashCode ^
        type.hashCode ^
        date.hashCode;
  }
}
