import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/invite_mapper.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class InviteRepository {
  /// Creates remotely an [Invite] with the provided [phoneNumber] and then saves it
  /// to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the new [Invite];
  ///
  /// returns:
  /// - the created [Invite];
  Future<Invite> create(String phoneNumber);

  /// Fetches from the API the [Invite] list tied to this account and saves it
  /// to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> sync();

  /// throws:
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a [Invite] model;
  ///
  /// returns:
  /// - the [Invite] list;
  Future<List<Invite>> get();

  /// Deletes the [Invite] with the provided [id];
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote deleting;
  /// - [DatabaseNotFoundException] when there is no [Invite] to delete with
  /// the provided [id];
  /// from the database;
  Future<void> delete(int id);

  /// Accept the [Invite] with the provided [id], then deletes it locally;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote accepting;
  /// - [DatabaseNotFoundException] when there is no [Invite] to delete with
  /// the provided [id];
  /// from the database;
  Future<void> accept(int id);
}

final inviteRepositoryProvider = Provider((ref) async {
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
  Future<Invite> create(String phoneNumber) async {
    final createdInvite = await _api.createInvite(phoneNumber);
    try {
      await _db.insert(
        InviteEntity.tableName,
        InviteMapper.toEntity(createdInvite).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
    return createdInvite;
  }

  @override
  Future<void> sync() async {
    final invites = await _api.getInvites();
    try {
      final batch = _db.batch();
      batch.delete(InviteEntity.tableName);
      for (final invite in invites) {
        batch.insert(
          InviteEntity.tableName,
          InviteMapper.toEntity(invite).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Invite>> get() async {
    final invitesMap = await _db.query(InviteEntity.tableName);

    try {
      return Future.wait(
        invitesMap.map((inviteMap) async {
          final entity = InviteEntity.fromMap(inviteMap);
          final doctorsMap = await _db.query(
            DoctorEntity.tableName,
            where: "${DoctorEntity.uuidColumn} = ?",
            whereArgs: [entity.doctorId],
          );
          final doctorEntity = DoctorEntity.fromMap(doctorsMap.first);
          return InviteMapper.toInvite(entity, doctorEntity: doctorEntity);
        }).toList(),
      );
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> accept(int id) async {
    await _api.acceptInvite(id);

    try {
      await _db.delete(
        InviteEntity.tableName,
        where: "${InviteEntity.idColumn} = ?",
        whereArgs: [id],
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> delete(int id) async {
    await _api.deleteInvite(id);

    try {
      await _db.delete(
        InviteEntity.tableName,
        where: "${InviteEntity.idColumn} = ?",
        whereArgs: [id],
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }
}
