import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';

class AdviceWithPatient {
  AdviceWithPatient({
    required this.adviceId,
    required this.patientId,
  });

  final int adviceId;
  final String patientId;

  static const String tableName = "advice_patients";
  static const String idColumn = "_id";
  static const String adviceIdColumn = "advice_id";
  static const String patientIdColumn = "patient_id";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY AUTOINCREMENT, 
     $adviceIdColumn INTEGER, 
     $patientIdColumn TEXT,
     FOREIGN KEY ($adviceIdColumn) REFERENCES ${AdviceEntity.tableName} (${AdviceEntity.idColumn}) ON DELETE CASCADE, 
     FOREIGN KEY ($patientIdColumn) REFERENCES ${PatientEntity.tableName} (${PatientEntity.uuidColumn}) ON DELETE CASCADE)
""";

  AdviceWithPatient copyWith({
    int? adviceId,
    String? patientId,
  }) {
    return AdviceWithPatient(
      adviceId: adviceId ?? this.adviceId,
      patientId: patientId ?? this.patientId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      adviceIdColumn: adviceId,
      patientIdColumn: patientId,
    };
  }

  factory AdviceWithPatient.fromMap(Map<String, dynamic> map) {
    return AdviceWithPatient(
      adviceId: map[adviceIdColumn] as int,
      patientId: map[patientIdColumn] as String,
    );
  }

  @override
  String toString() {
    return 'AdviceWithPatient(adviceId: $adviceId, patientId: $patientId)';
  }

  @override
  bool operator ==(covariant AdviceWithPatient other) {
    if (identical(this, other)) return true;

    return other.adviceId == adviceId && other.patientId == patientId;
  }

  @override
  int get hashCode {
    return adviceId.hashCode ^ patientId.hashCode;
  }
}
