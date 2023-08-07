import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/assignment_mapper.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class AssignmentRepository {
  /// Creates remotely an [Assignment] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the created [Assignment];
  Future<Assignment> create(Assignment assignment);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the updated [Assignment];
  Future<Assignment> update(Assignment assignment);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> delete(int id);

  /// returns:
  /// - the [Assignment] list of the [Patient] with [patientId];
  Future<List<Assignment>> getPatientAssignments(
    String patientId, {
    bool pending = false,
  });

  /// Fetches from the API the [Assignment] list from the [Patient] with the provided [patientId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> syncPatientAssignments(
    String patientId, {
    bool? pending,
  });

  /// Clears the table;
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
  Future<Assignment> create(Assignment assignment) async {
    final createdAssignment = await _api.createAssignment(assignment);
    await _db.insert(
      AssignmentEntity.tableName,
      AssignmentMapper.toEntity(createdAssignment).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return createdAssignment;
  }

  @override
  Future<Assignment> update(Assignment assignment) async {
    final updatedAssignment = await _api.updateAssignment(assignment);

    await _db.insert(
      AssignmentEntity.tableName,
      AssignmentMapper.toEntity(updatedAssignment).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return updatedAssignment;
  }

  @override
  Future<void> delete(int id) async {
    await _api.deleteAssignment(id);

    await _db.delete(
      AssignmentEntity.tableName,
      where: "${AssignmentEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> syncPatientAssignments(
    String patientId, {
    bool? pending,
  }) async {
    final assignments = await _api.getPatientAssignments(patientId, pending: pending);
    final batch = _db.batch();

    batch.delete(
      AssignmentEntity.tableName,
      where: "${AssignmentEntity.patientIdColumn} = ?"
          "${pending == true ? " AND ${AssignmentEntity.statusColumn} = ?" : ""}",
      whereArgs: [patientId, if (pending == true) AssignmentStatus.pending.value],
    );

    for (final assignment in assignments) {
      batch.insert(
        AssignmentEntity.tableName,
        AssignmentMapper.toEntity(assignment).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Assignment>> getPatientAssignments(
    String patientId, {
    bool pending = false,
  }) async {
    final assignmentsMap = await _db.query(
      AssignmentEntity.tableName,
      where: "${AssignmentEntity.patientIdColumn} = ?"
          "${pending ? " AND ${AssignmentEntity.statusColumn} = ?" : ""}",
      whereArgs: [patientId, if (pending) AssignmentStatus.pending.value],
    );

    final assignments = await Future.wait(assignmentsMap.mapToList((assignmentMap) async {
      final entity = AssignmentEntity.fromMap(assignmentMap);

      final doctorsMap = await _db.query(
        DoctorEntity.tableName,
        where: "${DoctorEntity.uuidColumn} = ?",
        whereArgs: [entity.doctorId],
      );
      final doctorEntity = DoctorEntity.fromMap(doctorsMap.first);

      final patientsMap = await _db.query(
        PatientEntity.tableName,
        where: "${PatientEntity.uuidColumn} = ?",
        whereArgs: [entity.patientId],
      );
      final patientEntity = PatientEntity.fromMap(patientsMap.first);

      final sessionsMap = await _db.query(
        SessionEntity.tableName,
        where: "${SessionEntity.idColumn} = ?",
        whereArgs: [entity.deliverySessionId],
      );
      final sessionEntity = SessionEntity.fromMap(sessionsMap.first);

      return AssignmentMapper.toAssignment(
        entity,
        doctorEntity: doctorEntity,
        patientEntity: patientEntity,
        sessionEntity: sessionEntity,
      );
    }));

    return assignments.sorted((a, b) => b.deliverySession.date.compareTo(a.deliverySession.date));
  }

  @override
  Future<void> clear() async {
    await _db.delete(AssignmentEntity.tableName);
  }
}
