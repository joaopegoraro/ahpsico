import 'dart:convert';

class MessageEntity {
  MessageEntity({
    required this.id,
    required this.text,
    required this.createdAtTimestamp,
  });

  final int id;
  final String text;
  final int createdAtTimestamp;

  static const tableName = "advices";
  static const idColumn = "_id";
  static const textColumn = "text_message";
  static const createdAtColumn = "created_at";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $textColumn TEXT,
     $createdAtColumn TIMESTAMP)
""";

  MessageEntity copyWith({
    int? id,
    String? text,
    int? createdAtTimestamp,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAtTimestamp: createdAtTimestamp ?? this.createdAtTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      textColumn: text,
      createdAtColumn: createdAtTimestamp,
    };
  }

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
      id: map[idColumn] as int,
      text: map[textColumn] as String,
      createdAtTimestamp: map[createdAtColumn] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageEntity.fromJson(String source) =>
      MessageEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant MessageEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.createdAtTimestamp == createdAtTimestamp;
  }

  @override
  String toString() =>
      'MessageEntity(id: $id, text: $text, createdAtTimestamp: $createdAtTimestamp)';

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ createdAtTimestamp.hashCode;
}
