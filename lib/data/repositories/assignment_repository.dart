import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/assignment_mapper.dart';
import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/constants/assignment_status.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class AssignmentRepository {
  Future<(Assignment?, ApiError?)> create(Assignment assignment);

  Future<(Assignment?, ApiError?)> update(Assignment assignment);

  Future<ApiError?> delete(int id);

  Future<List<Assignment>> getPatientAssignments(
    int patientId, {
    bool pending = false,
  });

  Future<ApiError?> syncPatientAssignments(
    int patientId, {
    bool? pending,
  });

  Future<void> clear();
}

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return AssignmentRepositoryImpl(apiService: apiService, database: database);
});

final class AssignmentRepositoryImpl implements AssignmentRepository {
  AssignmentRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<(Assignment?, ApiError?)> create(Assignment assignment) async {
    final (createdAssignment, err) = await _api.createAssignment(assignment);
    if (err != null) return (null, err);

    await _db.insert(
      AssignmentEntity.tableName,
      AssignmentMapper.toEntity(createdAssignment!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return (createdAssignment, null);
  }

  @override
  Future<(Assignment?, ApiError?)> update(Assignment assignment) async {
    final (updatedAssignment, err) = await _api.updateAssignment(assignment);
    if (err != null) return (null, err);

    await _db.insert(
      AssignmentEntity.tableName,
      AssignmentMapper.toEntity(updatedAssignment!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return (updatedAssignment, null);
  }

  @override
  Future<ApiError?> delete(int id) async {
    final err = await _api.deleteAssignment(id);
    if (err != null) return err;
    await _deleteLocally(id);
    return null;
  }

  @override
  Future<ApiError?> syncPatientAssignments(
    int patientId, {
    bool? pending,
  }) async {
    final (assignments, err) =
        await _api.getPatientAssignments(patientId, pending: pending);
    if (err != null) return err;

    final batch = _db.batch();
    batch.delete(
      AssignmentEntity.tableName,
      where: "${AssignmentEntity.userIdColumn} = ?"
          "${pending == true ? " AND ${AssignmentEntity.statusColumn} = ?" : ""}",
      whereArgs: [
        patientId,
        if (pending == true) AssignmentStatus.pending.value
      ],
    );

    for (final assignment in assignments!) {
      batch.insert(
        AssignmentEntity.tableName,
        AssignmentMapper.toEntity(assignment).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<List<Assignment>> getPatientAssignments(
    int patientId, {
    bool pending = false,
  }) async {
    final assignmentsMap = await _db.query(
      AssignmentEntity.tableName,
      where: "${AssignmentEntity.userIdColumn} = ?"
          "${pending ? " AND ${AssignmentEntity.statusColumn} = ?" : ""}",
      whereArgs: [patientId, if (pending) AssignmentStatus.pending.value],
    );

    final assignments = <Assignment>[];
    for (final assignmentMap in assignmentsMap) {
      final entity = AssignmentEntity.fromMap(assignmentMap);

      final patientsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.idColumn} = ?",
        whereArgs: [entity.userId],
      );
      if (patientsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final patientEntity =
          UserEntity.fromMap(patientsMap.firstOrNull ?? {"id": entity.userId});

      final sessionsMap = await _db.query(
        SessionEntity.tableName,
        where: "${SessionEntity.idColumn} = ?",
        whereArgs: [entity.sessionId],
      );
      if (sessionsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final sessionEntity = SessionEntity.fromMap(
        sessionsMap.firstOrNull ?? {"id": entity.sessionId},
      );

      assignments.add(AssignmentMapper.toAssignment(
        entity,
        userEntity: patientEntity,
        sessionEntity: sessionEntity,
      ));
    }

    return assignments.sorted((first, second) {
      return first.session.date.compareTo(second.session.date);
    });
  }

  @override
  Future<void> clear() async {
    await _db.delete(AssignmentEntity.tableName);
  }

  Future<void> _deleteLocally(int id) async {
    await _db.delete(
      AssignmentEntity.tableName,
      where: "${AssignmentEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }
}
