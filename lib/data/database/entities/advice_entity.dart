class AdviceEntity {
  AdviceEntity({
    required this.id,
    required this.message,
    required this.doctorId,
  });

  final int id;
  final String message;
  final String doctorId;

  static const tableName = "advices";
  static const idColumn = "_id";
  static const messageColumn = "message";
  static const doctorIdColumn = "doctor_id";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $messageColumn TEXT, 
     $doctorIdColumn TEXT)
""";

  AdviceEntity copyWith({
    int? id,
    String? message,
    String? doctorId,
  }) {
    return AdviceEntity(
      id: id ?? this.id,
      message: message ?? this.message,
      doctorId: doctorId ?? this.doctorId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      messageColumn: message,
      doctorIdColumn: doctorId,
    };
  }

  factory AdviceEntity.fromMap(Map<String, dynamic> map) {
    return AdviceEntity(
      id: map[idColumn] as int,
      message: map[messageColumn] as String,
      doctorId: map[doctorIdColumn] as String,
    );
  }

  @override
  String toString() {
    return 'AdviceEntity(id: $id, message: $message, doctorId: $doctorId)';
  }

  @override
  bool operator ==(covariant AdviceEntity other) {
    if (identical(this, other)) return true;

    return other.id == id && other.message == message && other.doctorId == doctorId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ message.hashCode ^ doctorId.hashCode;
  }
}
