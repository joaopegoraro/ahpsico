import "dart:convert";

class SessionEntity {
  SessionEntity({
    required this.id,
    required this.userId,
    required this.dateTimestamp,
    required this.groupIndex,
    required this.status,
    required this.type,
    required this.paymentStatus,
    required this.paymentType,
    required this.updatedBy,
    required this.updateMessage,
    required this.updatedAtTimestamp,
  });

  final int id;
  final int userId;
  final int dateTimestamp;
  final int groupIndex;
  final String status;
  final String type;
  final String? paymentStatus;
  final String paymentType;
  final String updatedBy;
  final String? updateMessage;
  final int updatedAtTimestamp;

  static const tableName = "sessions";
  static const idColumn = "_id";
  static const userIdColumn = "user_id";
  static const dateColumn = "date";
  static const groupIndexColumn = "group_index";
  static const statusColumn = "status";
  static const typeColumn = "type";
  static const paymentStatusColumn = "payment_status";
  static const paymentTypeColumn = "payment_type";
  static const updatedByColumn = "updated_by";
  static const updateMessageColumn = "update_message";
  static const updatedAtColumn = "updated_at";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $idColumn INTEGER PRIMARY KEY, 
     $userIdColumn INTEGER,
     $dateColumn TIMESTAMP,
     $groupIndexColumn INTEGER,
     $statusColumn TEXT,
     $typeColumn TEXT,
     $paymentStatusColumn TEXT,
     $paymentTypeColumn TEXT,
     $updatedByColumn TEXT,
     $updateMessageColumn TEXT,
     $updatedAtColumn TIMESTAMP
     )
""";

  SessionEntity copyWith({
    int? id,
    int? userId,
    int? dateTimestamp,
    int? groupIndex,
    String? status,
    String? type,
    String? paymentStatus,
    String? paymentType,
    String? updatedBy,
    String? updateMessage,
    int? updatedAtTimestamp,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateTimestamp: dateTimestamp ?? this.dateTimestamp,
      groupIndex: groupIndex ?? this.groupIndex,
      status: status ?? this.status,
      type: type ?? this.type,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentType: paymentType ?? this.paymentType,
      updatedBy: updatedBy ?? this.updatedBy,
      updateMessage: updateMessage ?? this.updateMessage,
      updatedAtTimestamp: updatedAtTimestamp ?? this.updatedAtTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      userIdColumn: userId,
      dateColumn: dateTimestamp,
      groupIndexColumn: groupIndex,
      statusColumn: status,
      typeColumn: type,
      paymentStatusColumn: paymentStatus,
      paymentTypeColumn: paymentType,
      updatedByColumn: updatedBy,
      updateMessageColumn: updateMessage,
      updatedAtColumn: updatedAtTimestamp,
    };
  }

  factory SessionEntity.fromMap(Map<String, dynamic> map) {
    return SessionEntity(
      id: map[idColumn] as int,
      userId: map[userIdColumn] as int,
      dateTimestamp: map[dateColumn] as int,
      groupIndex: map[groupIndexColumn] as int,
      status: map[statusColumn] as String,
      type: map[typeColumn] as String,
      paymentStatus: map[paymentStatusColumn] as String?,
      paymentType: map[paymentTypeColumn] as String,
      updatedBy: map[updatedByColumn] as String,
      updateMessage: map[updateMessageColumn] as String?,
      updatedAtTimestamp: map[updatedAtColumn] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SessionEntity.fromJson(String source) =>
      SessionEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SessionEntity(id: $id, userId: $userId, dateTimestamp: $dateTimestamp, groupIndex: $groupIndex, status: $status, type: $type, paymentStatus: $paymentStatus, paymentType: $paymentType, updatedBy: $updatedBy, updateMessage: $updateMessage, updatedAtTimestamp: $updatedAtTimestamp)';
  }

  @override
  bool operator ==(covariant SessionEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.dateTimestamp == dateTimestamp &&
        other.groupIndex == groupIndex &&
        other.status == status &&
        other.type == type &&
        other.paymentStatus == paymentStatus &&
        other.paymentType == paymentType &&
        other.updatedBy == updatedBy &&
        other.updateMessage == updateMessage &&
        other.updatedAtTimestamp == updatedAtTimestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        dateTimestamp.hashCode ^
        groupIndex.hashCode ^
        status.hashCode ^
        type.hashCode ^
        paymentStatus.hashCode ^
        paymentType.hashCode ^
        updatedBy.hashCode ^
        updateMessage.hashCode ^
        updatedAtTimestamp.hashCode;
  }
}
