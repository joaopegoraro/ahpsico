import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class SessionRepository {
  Future<(Session?, ApiError?)> create(Session session);

  Future<(Session?, ApiError?)> update(Session session);

  Future<List<Session>> getPatientSessions(
    String patientId, {
    bool upcoming = false,
  });

  Future<ApiError?> syncPatientSessions(
    String patientId, {
    bool? upcoming,
  });

  Future<List<Session>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

  Future<ApiError?> syncDoctorSessions(
    String doctorId, {
    DateTime? date,
  });

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
  Future<(Session?, ApiError?)> create(Session session) async {
    final (createdSession, err) = await _api.createSession(session);
    if (err != null) return (null, err);

    await _db.insert(
      SessionEntity.tableName,
      SessionMapper.toEntity(createdSession!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return (createdSession, null);
  }

  @override
  Future<(Session?, ApiError?)> update(Session session) async {
    final (updatedSession, err) = await _api.updateSession(session);
    if (err != null) return (null, err);

    await _db.insert(
      SessionEntity.tableName,
      SessionMapper.toEntity(updatedSession!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return (updatedSession, err);
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
          "${SessionEntity.patientIdColumn} = ?${upcoming ? " AND ${SessionEntity.dateColumn} >= ?" : ""} ORDER BY ${SessionEntity.dateColumn} ASC",
      whereArgs: [patientId, if (upcoming) now],
    );

    final sessions = <Session>[];
    for (final sessionMap in sessionsMap) {
      final entity = SessionEntity.fromMap(sessionMap);
      final nonUpcomingStatus = [SessionStatus.canceled.value, SessionStatus.concluded.value];
      if (upcoming && nonUpcomingStatus.contains(entity.status)) {
        continue;
      }

      final doctorsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [entity.doctorId],
      );
      if (doctorsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final doctorEntity = UserEntity.fromMap(doctorsMap.first);

      final patientsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [patientId],
      );
      if (patientsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final patientEntity = UserEntity.fromMap(patientsMap.first);

      sessions.add(SessionMapper.toSession(
        entity,
        doctorEntity: doctorEntity,
        patientEntity: patientEntity,
      ));
    }

    return sessions;
  }

  @override
  Future<ApiError?> syncPatientSessions(
    String patientId, {
    bool? upcoming,
  }) async {
    final (sessions, err) = await _api.getPatientSessions(patientId, upcoming: upcoming);
    if (err != null) return err;

    // substract one hour so ongoing sessions also count as upcoming
    final now = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;

    final batch = _db.batch();
    batch.delete(
      SessionEntity.tableName,
      where:
          "${SessionEntity.patientIdColumn} = ?${upcoming == true ? " AND ${SessionEntity.dateColumn} >= ?" : ""}",
      whereArgs: [patientId, if (upcoming == true) now],
    );

    for (final session in sessions!) {
      batch.insert(
        SessionEntity.tableName,
        SessionMapper.toEntity(session).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<List<Session>> getDoctorSessions(
    String doctorId, {
    DateTime? date,
  }) async {
    final startOfToday = date != null ? DateTime(date.year, date.month, date.day) : null;

    final tomorrow = date?.add(const Duration(days: 1));
    final startOfTomorrow =
        tomorrow != null ? DateTime(tomorrow.year, tomorrow.month, tomorrow.day) : null;

    final sessionsMap = await _db.query(
      SessionEntity.tableName,
      where: "${SessionEntity.doctorIdColumn} = ?"
          "${date == null ? "" : " AND ${SessionEntity.dateColumn} >= ? AND ${SessionEntity.dateColumn} <= ?"} ORDER BY ${SessionEntity.dateColumn} ASC",
      whereArgs: [
        doctorId,
        if (startOfToday != null && startOfTomorrow != null) ...[
          startOfToday.millisecondsSinceEpoch,
          startOfTomorrow.millisecondsSinceEpoch,
        ]
      ],
    );

    final sessions = <Session>[];
    for (final sessionMap in sessionsMap) {
      final entity = SessionEntity.fromMap(sessionMap);

      final doctorsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [doctorId],
      );
      if (doctorsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final doctorEntity = UserEntity.fromMap(doctorsMap.first);

      final patientsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [entity.patientId],
      );
      if (patientsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final patientEntity = UserEntity.fromMap(patientsMap.first);

      sessions.add(SessionMapper.toSession(
        entity,
        doctorEntity: doctorEntity,
        patientEntity: patientEntity,
      ));
    }

    return sessions;
  }

  @override
  Future<ApiError?> syncDoctorSessions(
    String doctorId, {
    DateTime? date,
  }) async {
    final (sessions, err) = await _api.getDoctorSessions(doctorId, date: date);
    if (err != null) return err;

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

    for (final session in sessions!) {
      batch.insert(
        SessionEntity.tableName,
        SessionMapper.toEntity(session).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<void> clear() async {
    await _db.delete(SessionEntity.tableName);
  }

  Future<void> _deleteLocally(int id) async {
    await _db.delete(
      SessionEntity.tableName,
      where: "${SessionEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }
}
