import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class SessionRepository {
  /// Creates remotely an [Session] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting
  /// the new [Session];
  ///
  /// returns:
  /// - the created [Session];
  Future<Session> create(Session session);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote updating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  ///
  /// returns:
  /// - the updated [Session];
  Future<Session> update(Session session);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Session] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Session] models;
  ///
  /// returns:
  /// - the [Session] list of the [Patient] with [patientId];
  Future<List<Session>> getPatientSessions(String patientId);

  /// Fetches from the API the [Session] list from the [Patient] with the provided [patientId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncPatientSessions(String patientId);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Session] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Session] models;
  ///
  /// returns:
  /// - the [Session] list of the [Doctor] with [doctorId];
  Future<List<Session>> getDoctorSessions(String doctorId);

  /// Fetches from the API the [Session] list from the [Doctor] with the provided [doctorId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncDoctorSessions(String doctorId);

  /// Clears the table;
  ///
  /// throws:
  /// - [DatabaseInsertException] when something goes wrong when deleting the data;
  Future<void> clear();
}

final sessionRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return SessionRepositoryImpl(apiService: apiService, database: database);
});

final class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<Session> create(Session session) async {
    final createdSession = await _api.createSession(session);
    try {
      await _db.insert(
        SessionEntity.tableName,
        SessionMapper.toEntity(createdSession).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      return createdSession;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Session> update(Session session) async {
    final updatedSession = await _api.updateSession(session);

    try {
      await _db.insert(
        SessionEntity.tableName,
        SessionMapper.toEntity(updatedSession).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );

      return updatedSession;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Session>> getPatientSessions(String patientId) async {
    try {
      final sessionsMap = await _db.query(
        SessionEntity.tableName,
        where: "${SessionEntity.patientIdColumn} = ?",
        whereArgs: [patientId],
      );

      final sessions = sessionsMap.map((sessionMap) async {
        final entity = SessionEntity.fromMap(sessionMap);

        final doctorsMap = await _db.query(
          DoctorEntity.tableName,
          where: "${DoctorEntity.uuidColumn} = ?",
          whereArgs: [entity.doctorId],
        );
        final doctorEntity = DoctorEntity.fromMap(doctorsMap.first);

        final patientsMap = await _db.query(
          PatientEntity.tableName,
          where: "${PatientEntity.uuidColumn} = ?",
          whereArgs: [patientId],
        );
        final patientEntity = PatientEntity.fromMap(patientsMap.first);

        return SessionMapper.toSession(
          entity,
          doctorEntity: doctorEntity,
          patientEntity: patientEntity,
        );
      });

      return Future.wait(sessions.toList());
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncPatientSessions(String patientId) async {
    final sessions = await _api.getPatientSessions(patientId);
    try {
      final batch = _db.batch();

      batch.delete(
        SessionEntity.tableName,
        where: "${SessionEntity.patientIdColumn} = ?",
        whereArgs: [patientId],
      );

      for (final session in sessions) {
        batch.insert(
          SessionEntity.tableName,
          SessionMapper.toEntity(session).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Session>> getDoctorSessions(String doctorId) async {
    try {
      final sessionsMap = await _db.query(
        SessionEntity.tableName,
        where: "${SessionEntity.doctorIdColumn} = ?",
        whereArgs: [doctorId],
      );

      final sessions = sessionsMap.map((sessionMap) async {
        final entity = SessionEntity.fromMap(sessionMap);

        final doctorsMap = await _db.query(
          DoctorEntity.tableName,
          where: "${DoctorEntity.uuidColumn} = ?",
          whereArgs: [doctorId],
        );
        final doctorEntity = DoctorEntity.fromMap(doctorsMap.first);

        final patientsMap = await _db.query(
          PatientEntity.tableName,
          where: "${PatientEntity.uuidColumn} = ?",
          whereArgs: [entity.patientId],
        );
        final patientEntity = PatientEntity.fromMap(patientsMap.first);

        return SessionMapper.toSession(
          entity,
          doctorEntity: doctorEntity,
          patientEntity: patientEntity,
        );
      });

      return Future.wait(sessions.toList());
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncDoctorSessions(String doctorId) async {
    final sessions = await _api.getDoctorSessions(doctorId);
    try {
      final batch = _db.batch();

      batch.delete(
        SessionEntity.tableName,
        where: "${SessionEntity.doctorIdColumn} = ?",
        whereArgs: [doctorId],
      );

      for (final session in sessions) {
        batch.insert(
          SessionEntity.tableName,
          SessionMapper.toEntity(session).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> clear() async {
    await _db.delete(SessionEntity.tableName);
  }
}
