import "dart:convert";

class AssignmentEntity {
  AssignmentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.status,
    required this.sessionId,
  });

  final int id;
  final String title;
  final String description;
  final int userId;
  final String status;
  final int sessionId;

  static const tableName = "assignments";
  static const idColumn = "_id";
  static const titleColumn = "title";
  static const descriptionColumn = "description";
  static const userIdColumn = "user_id";
  static const statusColumn = "status";
  static const sessionIdColumn = "session_id";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $titleColumn TEXT,
     $descriptionColumn TEXT,
     $userIdColumn TEXT,
     $statusColumn TEXT,
     $sessionIdColumn INTEGER)
""";

  AssignmentEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? userId,
    String? status,
    int? sessionId,
  }) {
    return AssignmentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      titleColumn: title,
      descriptionColumn: description,
      userIdColumn: userId,
      statusColumn: status,
      sessionIdColumn: sessionId,
    };
  }

  factory AssignmentEntity.fromMap(Map<String, dynamic> map) {
    return AssignmentEntity(
      id: map[idColumn] as int,
      title: map[titleColumn] as String,
      description: map[descriptionColumn] as String,
      userId: map[userIdColumn] as int,
      status: map[statusColumn] as String,
      sessionId: map[sessionIdColumn] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AssignmentEntity.fromJson(String source) =>
      AssignmentEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AssignmentEntity(id: $id, title: $title, description: $description, userId: $userId, status: $status, sessionId: $sessionId)';
  }

  @override
  bool operator ==(covariant AssignmentEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.userId == userId &&
        other.status == status &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        sessionId.hashCode;
  }
}
