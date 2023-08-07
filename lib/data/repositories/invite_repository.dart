import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/mappers/invite_mapper.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class InviteRepository {
  /// Creates remotely an [Invite] with the provided [phoneNumber] and then saves it
  /// to the local database;
  ///
  /// throws:
  /// - [ApiPatientNotRegisteredException] when there is no patient registered
  /// with the phone number that was passed;
  /// - [ApiPatientAlreadyWithDoctorException] when the patient you are trying to
  /// invite already is your patient;
  /// - [ApiInviteAlreadySentException] when this invite was already sent to the patient;
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the created [Invite];
  Future<Invite> create(String phoneNumber);

  /// Fetches from the API the [Invite] list tied to this account and saves it
  /// to the local database;
  ///
  /// throws:
  /// - [ApiInvitesNotFoundException] when there are no invites tied to this account
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> sync();

  /// returns:
  /// - the [Invite] list;
  Future<List<Invite>> get();

  /// Deletes the [Invite] with the provided [id];
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> delete(int id);

  /// Accept the [Invite] with the provided [id], then deletes it locally;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> accept(int id);

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
  Future<Invite> create(String phoneNumber) async {
    final createdInvite = await _api.createInvite(phoneNumber);
    await _db.insert(
      InviteEntity.tableName,
      InviteMapper.toEntity(createdInvite).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return createdInvite;
  }

  @override
  Future<void> sync() async {
    final invites = await _api.getInvites();
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
  Future<void> accept(int id) async {
    await _api.acceptInvite(id);

    await _db.delete(
      InviteEntity.tableName,
      where: "${InviteEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _api.deleteInvite(id);

    await _db.delete(
      InviteEntity.tableName,
      where: "${InviteEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> clear() async {
    await _db.delete(InviteEntity.tableName);
  }
}
