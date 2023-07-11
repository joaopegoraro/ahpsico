import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/assignment_mapper.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class AssignmentRepository {
  /// Creates remotely an [Assignment] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting
  /// the new [Assignment];
  ///
  /// returns:
  /// - the created [Assignment];
  Future<Assignment> create(Assignment assignment);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote updating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  ///
  /// returns:
  /// - the updated [Assignment];
  Future<Assignment> update(Assignment assignment);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Assignment] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Assignment] models;
  ///
  /// returns:
  /// - the [Assignment] list of the [Patient] with [patientId];
  Future<List<Assignment>> getPatientAssignments(String patientId);

  /// Fetches from the API the [Assignment] list from the [Doctor] with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncPatientAssignments(String patientId);
}

final assignmentRepositoryProvider = Provider((ref) {
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
    try {
      await _db.insert(
        AssignmentEntity.tableName,
        AssignmentMapper.toEntity(createdAssignment).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      return createdAssignment;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Assignment> update(Assignment assignment) async {
    final updatedAssignment = await _api.updateAssignment(assignment);

    try {
      await _db.insert(
        AssignmentEntity.tableName,
        AssignmentMapper.toEntity(updatedAssignment).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );

      return updatedAssignment;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncPatientAssignments(String patientId) async {
    final assignments = await _api.getPatientAssignments(patientId);
    try {
      final batch = _db.batch();

      batch.delete(
        AssignmentEntity.tableName,
        where: "${AssignmentEntity.patientIdColumn} = ?",
        whereArgs: [patientId],
      );

      for (final assignment in assignments) {
        batch.insert(
          AssignmentEntity.tableName,
          assignment.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Assignment>> getPatientAssignments(String patientId) async {
    try {
      final assignmentsMap = await _db.query(
        AssignmentEntity.tableName,
        where: "${AssignmentEntity.patientIdColumn} = ?",
        whereArgs: [patientId],
      );

      final assignments = Future.wait(assignmentsMap.map((assignmentMap) async {
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
      }).toList());
      return assignments;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }
}
