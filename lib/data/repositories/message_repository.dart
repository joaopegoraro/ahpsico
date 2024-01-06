import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/message_entity.dart';
import 'package:ahpsico/data/database/mappers/message_mapper.dart';
import 'package:ahpsico/models/message.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class MessageRepository {
  Future<(Message?, ApiError?)> create(
    Message message, {
    required List<int> userIds,
  });

  Future<ApiError?> delete(int id);

  Future<List<Message>> getMessages();

  Future<ApiError?> syncPatientMessages(int patientId);

  Future<ApiError?> syncDoctorMessages();

  Future<int> clear();
}

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return MessageRepositoryImpl(apiService: apiService, database: database);
});

final class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<(Message?, ApiError?)> create(
    Message message, {
    required List<int> userIds,
  }) async {
    final (createdMessage, err) = await _api.createMessage(
      message,
      userIds: userIds,
    );
    if (err != null) return (createdMessage, err);
    await _db.insert(
      MessageEntity.tableName,
      MessageMapper.toEntity(createdMessage!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return (createdMessage, null);
  }

  @override
  Future<ApiError?> delete(int id) async {
    final err = await _api.deleteMessage(id);
    if (err != null) return err;
    await _deleteLocally(id);
    return null;
  }

  @override
  Future<List<Message>> getMessages() async {
    final messagesMap = await _db.query(MessageEntity.tableName);

    return messagesMap.mapToList((messageMap) {
      final entity = MessageEntity.fromMap(messageMap);
      return MessageMapper.toMessage(entity);
    });
  }

  @override
  Future<ApiError?> syncPatientMessages(int patientId) async {
    final (advices, err) = await _api.getPatientMessages(patientId);
    if (err != null) return err;

    final batch = _db.batch();
    batch.delete(MessageEntity.tableName);

    for (final advice in advices!) {
      batch.insert(
        MessageEntity.tableName,
        MessageMapper.toEntity(advice).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<ApiError?> syncDoctorMessages() async {
    final (advices, err) = await _api.getDoctorMessages();
    if (err != null) return err;

    final batch = _db.batch();
    batch.delete(MessageEntity.tableName);

    for (final message in advices!) {
      batch.insert(
        MessageEntity.tableName,
        MessageMapper.toEntity(message).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<int> clear() async {
    return await _db.delete(MessageEntity.tableName);
  }

  Future<void> _deleteLocally(int id) async {
    await _db.delete(
      MessageEntity.tableName,
      where: "${MessageEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }
}
