import 'package:ahpsico/data/database/entities/user_entity.dart';

class PatientWithDoctor {
  PatientWithDoctor({
    required this.patientId,
    required this.doctorId,
  });

  final String patientId;
  final String doctorId;

  static const String tableName = "patient_doctor";
  static const String idColumn = "_id";
  static const String patientIdColumn = "patient_id";
  static const String doctorIdColumn = "doctor_id";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY AUTOINCREMENT, 
     $patientIdColumn TEXT,
     $doctorIdColumn TEXT,
     FOREIGN KEY ($patientIdColumn) REFERENCES ${UserEntity.tableName} (${UserEntity.uuidColumn}) ON DELETE CASCADE,
     FOREIGN KEY ($doctorIdColumn) REFERENCES ${UserEntity.tableName} (${UserEntity.uuidColumn}) ON DELETE CASCADE)
""";

  PatientWithDoctor copyWith({
    String? patientId,
    String? doctorId,
  }) {
    return PatientWithDoctor(
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      patientIdColumn: patientId,
      doctorIdColumn: doctorId,
    };
  }

  factory PatientWithDoctor.fromMap(Map<String, dynamic> map) {
    return PatientWithDoctor(
      patientId: map[patientIdColumn] as String,
      doctorId: map[doctorIdColumn] as String,
    );
  }

  @override
  String toString() {
    return 'PatientWithDoctor(patientId: $patientId, doctorId: $doctorId)';
  }

  @override
  bool operator ==(covariant PatientWithDoctor other) {
    if (identical(this, other)) return true;

    return other.patientId == patientId && other.doctorId == doctorId;
  }

  @override
  int get hashCode {
    return patientId.hashCode ^ doctorId.hashCode;
  }
}
