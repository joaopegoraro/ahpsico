import 'dart:convert';

import 'package:ahpsico/constants/assignment_status.dart';
import 'package:ahpsico/models/session.dart';

class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.status,
    required this.session,
  });

  final int id;
  final String title;
  final String description;
  final int userId;
  final AssignmentStatus status;
  final Session session;

  Assignment copyWith({
    int? id,
    String? title,
    String? description,
    int? userId,
    AssignmentStatus? status,
    Session? session,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      session: session ?? this.session,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'status': status.value,
      'session': session.toMap(),
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      userId: map['userId'] as int,
      status: AssignmentStatus.fromValue(map['status']),
      session: Session.fromMap(map['session'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Assignment.fromJson(String source) =>
      Assignment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, description: $description, userId: $userId, status: $status, session: $session)';
  }

  @override
  bool operator ==(covariant Assignment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.userId == userId &&
        other.status == status &&
        other.session == session;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        session.hashCode;
  }
}
