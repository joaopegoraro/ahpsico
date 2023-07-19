import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class SessionRepository {
  /// Creates remotely an [Session] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the created [Session];
  Future<Session> create(Session session);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the updated [Session];
  Future<Session> update(Session session);

  /// returns:
  /// - the [Session] list of the [Patient] with [patientId];
  Future<List<Session>> getPatientSessions(
    String patientId, {
    bool upcoming = false,
  });

  /// Fetches from the API the [Session] list from the [Patient] with the provided [patientId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> syncPatientSessions(
    String patientId, {
    bool? upcoming,
  });

  /// returns:
  /// - the [Session] list of the [Doctor] with [doctorId];
  Future<List<Session>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  /// Fetches from the API the [Session] list from the [Doctor] with the provided [doctorId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> syncDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  /// Clears the table;
  Future<void> clear();
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
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
    await _db.insert(
      SessionEntity.tableName,
      SessionMapper.toEntity(createdSession).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return createdSession;
  }

  @override
  Future<Session> update(Session session) async {
    final updatedSession = await _api.updateSession(session);

    await _db.insert(
      SessionEntity.tableName,
      SessionMapper.toEntity(updatedSession).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return updatedSession;
  }

  @override
  Future<List<Session>> getPatientSessions(
    String patientId, {
    bool upcoming = false,
  }) async {
    // substract one hour so ongoing sessions also count as upcoming
    final now = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
    final sessionsMap = await _db.query(
      SessionEntity.tableName,
      where:
          "${SessionEntity.patientIdColumn} = ?${upcoming ? " AND ${SessionEntity.dateColumn} >= ?" : ""} ORDER BY ${SessionEntity.dateColumn} DESC",
      whereArgs: [patientId, if (upcoming) now],
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
  }

  @override
  Future<void> syncPatientSessions(
    String patientId, {
    bool? upcoming,
  }) async {
    // substract one hour so ongoing sessions also count as upcoming
    final now = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
    final sessions = await _api.getPatientSessions(patientId, upcoming: upcoming);
    final batch = _db.batch();

    batch.delete(
      SessionEntity.tableName,
      where: "${SessionEntity.patientIdColumn} = ?${upcoming == true ? " AND ${SessionEntity.dateColumn} >= ?" : ""}",
      whereArgs: [patientId, if (upcoming == true) now],
    );

    for (final session in sessions) {
      batch.insert(
        SessionEntity.tableName,
        SessionMapper.toEntity(session).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Session>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  }) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final tomorrow = today.add(const Duration(days: 1));
    final startOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    final sessionsMap = await _db.query(
      SessionEntity.tableName,
      where: "${SessionEntity.doctorIdColumn} = ?"
          "${date == null ? "" : " AND ${SessionEntity.dateColumn} >= ? AND ${SessionEntity.dateColumn} <= ?"} ORDER BY ${SessionEntity.dateColumn} DESC",
      whereArgs: [
        doctorId,
        if (date != null) ...[
          startOfToday.millisecondsSinceEpoch,
          startOfTomorrow.millisecondsSinceEpoch,
        ]
      ],
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
  }

  @override
  Future<void> syncDoctorSessions(
    String doctorId, {
    DateTime? date,
  }) async {
    final sessions = await _api.getDoctorSessions(doctorId, date: date);
    final batch = _db.batch();

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final tomorrow = today.add(const Duration(days: 1));
    final startOfTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    batch.delete(
      SessionEntity.tableName,
      where: "${SessionEntity.doctorIdColumn} = ?"
          "${date == null ? "" : " AND ${SessionEntity.dateColumn} >= ? AND ${SessionEntity.dateColumn} <= ?"}",
      whereArgs: [
        doctorId,
        if (date != null) ...[
          startOfToday.millisecondsSinceEpoch,
          startOfTomorrow.millisecondsSinceEpoch,
        ]
      ],
    );

    for (final session in sessions) {
      batch.insert(
        SessionEntity.tableName,
        SessionMapper.toEntity(session).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clear() async {
    await _db.delete(SessionEntity.tableName);
  }
}
