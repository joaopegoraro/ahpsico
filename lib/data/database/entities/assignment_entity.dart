import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';

class AssignmentEntity {
  AssignmentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.deliverySessionId,
  });

  final int id;
  final String title;
  final String description;
  final String doctorId;
  final String patientId;
  final String status;
  final int deliverySessionId;

  static const tableName = "assignments";
  static const idColumn = "_id";
  static const titleColumn = "title";
  static const descriptionColumn = "description";
  static const doctorIdColumn = "doctor_id";
  static const patientIdColumn = "patient_id";
  static const statusColumn = "status";
  static const deliverySessionIdColumn = "delivery_session_id";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $titleColumn TEXT,
     $descriptionColumn TEXT,
     $doctorIdColumn TEXT,
     $patientIdColumn TEXT,
     $statusColumn TEXT,
     $deliverySessionIdColumn INTEGER,
     FOREIGN KEY ($doctorIdColumn) REFERENCES Type (${DoctorEntity.uuidColumn}) ON DELETE CASCADE, 
     FOREIGN KEY ($patientIdColumn) REFERENCES Type (${PatientEntity.uuidColumn}) ON DELETE CASCADE, 
     FOREIGN KEY ($deliverySessionIdColumn) REFERENCES Type (${SessionEntity.idColumn}) ON DELETE CASCADE)
""";

  AssignmentEntity copyWith({
    int? id,
    String? title,
    String? description,
    String? doctorId,
    String? patientId,
    String? status,
    int? deliverySessionId,
  }) {
    return AssignmentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      status: status ?? this.status,
      deliverySessionId: deliverySessionId ?? this.deliverySessionId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      titleColumn: title,
      descriptionColumn: description,
      doctorIdColumn: doctorId,
      patientIdColumn: patientId,
      statusColumn: status,
      deliverySessionIdColumn: deliverySessionId,
    };
  }

  factory AssignmentEntity.fromMap(Map<String, dynamic> map) {
    return AssignmentEntity(
      id: map[idColumn] as int,
      title: map[titleColumn] as String,
      description: map[descriptionColumn] as String,
      doctorId: map[doctorIdColumn] as String,
      patientId: map[patientIdColumn] as String,
      status: map[statusColumn] as String,
      deliverySessionId: map[deliverySessionIdColumn] as int,
    );
  }

  @override
  String toString() {
    return 'AssignmentEntity(id: $id, title: $title, description: $description, doctorId: $doctorId, patientId: $patientId, status: $status, deliverySessionId: $deliverySessionId)';
  }

  @override
  bool operator ==(covariant AssignmentEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.doctorId == doctorId &&
        other.patientId == patientId &&
        other.status == status &&
        other.deliverySessionId == deliverySessionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        doctorId.hashCode ^
        patientId.hashCode ^
        status.hashCode ^
        deliverySessionId.hashCode;
  }
}
