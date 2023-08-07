import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/mappers/invite_mapper.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class InviteRepository {
  Future<(Invite?, ApiError?)> create(String phoneNumber);

  Future<ApiError?> sync();

  Future<List<Invite>> get();

  Future<ApiError?> delete(int id);

  Future<ApiError?> accept(int id);

  /// Clears the table;
  Future<void> clear();
}

final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return InviteRepositoryImpl(apiService: apiService, database: database);
});

final class InviteRepositoryImpl implements InviteRepository {
  InviteRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<(Invite?, ApiError?)> create(String phoneNumber) async {
    final (createdInvite, err) = await _api.createInvite(phoneNumber);
    if (err != null) return (null, err);

    await _db.insert(
      InviteEntity.tableName,
      InviteMapper.toEntity(createdInvite!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return (createdInvite, null);
  }

  @override
  Future<ApiError?> sync() async {
    final (invites, err) = await _api.getInvites();
    if (err != null) return err;

    final batch = _db.batch();
    batch.delete(InviteEntity.tableName);
    for (final invite in invites!) {
      batch.insert(
        InviteEntity.tableName,
        InviteMapper.toEntity(invite).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<List<Invite>> get() async {
    final invitesMap = await _db.query(InviteEntity.tableName);

    return Future.wait(
      invitesMap.map((inviteMap) async {
        final entity = InviteEntity.fromMap(inviteMap);
        final doctorsMap = await _db.query(
          UserEntity.tableName,
          where: "${UserEntity.uuidColumn} = ?",
          whereArgs: [entity.doctorId],
        );
        final doctorEntity = UserEntity.fromMap(doctorsMap.first);
        return InviteMapper.toInvite(entity, doctorEntity: doctorEntity);
      }).toList(),
    );
  }

  @override
  Future<ApiError?> accept(int id) async {
    final err = await _api.acceptInvite(id);
    if (err != null) return err;

    await _db.delete(
      InviteEntity.tableName,
      where: "${InviteEntity.idColumn} = ?",
      whereArgs: [id],
    );

    return null;
  }

  @override
  Future<ApiError?> delete(int id) async {
    final err = await _api.deleteInvite(id);
    if (err != null) return err;

    await _db.delete(
      InviteEntity.tableName,
      where: "${InviteEntity.idColumn} = ?",
      whereArgs: [id],
    );

    return null;
  }

  @override
  Future<void> clear() async {
    await _db.delete(InviteEntity.tableName);
  }
}
