import 'dart:convert';

import 'package:flutter/foundation.dart';

class Message {
  const Message({
    required this.id,
    required this.text,
    required this.userIds,
    required this.createdAt,
  });

  final int id;
  final String text;
  final List<int> userIds;
  final DateTime createdAt;

  Message copyWith({
    int? id,
    String? text,
    List<int>? userIds,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      userIds: userIds ?? this.userIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'userIds': userIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      text: map['text'] as String,
      userIds: List<int>.from(map['userIds']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, text: $text, userIds: $userIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        listEquals(other.userIds, userIds) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ text.hashCode ^ userIds.hashCode ^ createdAt.hashCode;
  }
}
