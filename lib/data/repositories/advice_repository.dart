import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/entities/advice_with_patient.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/advice_mapper.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class AdviceRepository {
  /// Creates remotely an [Advice] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting
  /// the new [Advice];
  ///
  /// returns:
  /// - the created [Advice];
  Future<Advice> create(Advice advice);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote updating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  ///
  /// returns:
  /// - the updated [Advice];
  Future<Advice> update(Advice advice);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote deleting;
  /// - [DatabaseInsertException] when something goes wrong when deleting data;
  Future<void> delete(int id);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Advice] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Advice] models;
  ///
  /// returns:
  /// - the [Advice] list of the [Patient] with [patientId];
  Future<List<Advice>> getPatientAdvices(String patientId);

  /// Fetches from the API the [Advice] list from the [Patient] with the provided [patientId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncPatientAdvices(String patientId);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Advice] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Advice] models;
  ///
  /// returns:
  /// - the [Advice] list of the [Doctor] with [doctorId];
  Future<List<Advice>> getDoctorAdvices(String doctorId);

  /// Fetches from the API the [Advice] list from the [Doctor] with the provided [doctorId]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncDoctorAdvices(String doctorId);

  /// Clears the table;
  ///
  /// throws:
  /// - [DatabaseInsertException] when something goes wrong when deleting the data;
  Future<int> clear();
}

final adviceRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return AdviceRepositoryImpl(apiService: apiService, database: database);
});

final class AdviceRepositoryImpl implements AdviceRepository {
  AdviceRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<Advice> create(Advice advice) async {
    final createdAdvice = await _api.createAdvice(advice);
    try {
      await _db.insert(
        AdviceEntity.tableName,
        AdviceMapper.toEntity(createdAdvice).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      return createdAdvice;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Advice> update(Advice advice) async {
    final updatedAdvice = await _api.updateAdvice(advice);

    try {
      await _db.insert(
        AdviceEntity.tableName,
        AdviceMapper.toEntity(updatedAdvice).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );

      return updatedAdvice;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> delete(int id) async {
    await _api.deleteAdvice(id);

    try {
      await _db.delete(
        AdviceEntity.tableName,
        where: "${AdviceEntity.idColumn} = ?",
        whereArgs: [id],
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Advice>> getPatientAdvices(String patientId) async {
    try {
      final advicesMap = await _db.rawQuery(
        """
        SELECT a.* FROM ${AdviceEntity.tableName} a  
          LEFT JOIN ${AdviceWithPatient.tableName} ap ON ap.${AdviceWithPatient.adviceIdColumn} = a.${AdviceEntity.idColumn}  
          WHERE ap.${AdviceWithPatient.patientIdColumn} = ?
        """,
        [patientId],
      );

      final advices = advicesMap.map((adviceMap) async {
        final entity = AdviceEntity.fromMap(adviceMap);

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
        final patientIds = patientsMap.map((patient) {
          final patientEntity = PatientEntity.fromMap(patientsMap.first);
          return patientEntity.uuid;
        });
        return AdviceMapper.toAdvice(
          entity,
          doctorEntity: doctorEntity,
          patientIds: patientIds.toList(),
        );
      });

      return Future.wait(advices.toList());
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncPatientAdvices(String patientId) async {
    final advices = await _api.getPatientAdvices(patientId);
    try {
      final batch = _db.batch();

      batch.rawDelete(
        """
        DELETE FROM ${AdviceEntity.tableName} WHERE ${AdviceEntity.idColumn} in (
          SELECT a.${AdviceEntity.idColumn} FROM ${AdviceEntity.tableName} a  
           LEFT JOIN ${AdviceWithPatient.tableName} ap ON ap.${AdviceWithPatient.adviceIdColumn} = a.${AdviceEntity.idColumn}  
           WHERE ap.${AdviceWithPatient.patientIdColumn} = ?)
        """,
        [patientId],
      );

      for (final advice in advices) {
        batch.insert(
          AdviceEntity.tableName,
          AdviceMapper.toEntity(advice).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
        batch.insert(
          AdviceWithPatient.tableName,
          AdviceWithPatient(adviceId: advice.id, patientId: patientId).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Advice>> getDoctorAdvices(String doctorId) async {
    try {
      final advicesMap = await _db.query(
        AdviceEntity.tableName,
        where: "${AdviceEntity.doctorIdColumn} = ?",
        whereArgs: [doctorId],
      );

      final advices = advicesMap.map((adviceMap) async {
        final entity = AdviceEntity.fromMap(adviceMap);

        final doctorsMap = await _db.query(
          DoctorEntity.tableName,
          where: "${DoctorEntity.uuidColumn} = ?",
          whereArgs: [doctorId],
        );
        final doctorEntity = DoctorEntity.fromMap(doctorsMap.first);

        final patientsMap = await _db.rawQuery(
          """
          SELECT  p.* FROM ${PatientEntity.tableName} p  
            LEFT JOIN ${AdviceWithPatient.tableName} ad ON ad.${AdviceWithPatient.patientIdColumn} = p.${PatientEntity.uuidColumn}  
            WHERE ad.${AdviceWithPatient.adviceIdColumn} = ?
          """,
          [entity.id],
        );
        final patientIds = patientsMap.map((patient) {
          final patientEntity = PatientEntity.fromMap(patientsMap.first);
          return patientEntity.uuid;
        });

        return AdviceMapper.toAdvice(
          entity,
          doctorEntity: doctorEntity,
          patientIds: patientIds.toList(),
        );
      });

      return Future.wait(advices.toList());
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncDoctorAdvices(String doctorId) async {
    final advices = await _api.getDoctorAdvices(doctorId);
    try {
      final batch = _db.batch();

      batch.delete(
        AdviceEntity.tableName,
        where: "${AdviceEntity.doctorIdColumn} = ?",
        whereArgs: [doctorId],
      );

      for (final advice in advices) {
        batch.insert(
          AdviceEntity.tableName,
          AdviceMapper.toEntity(advice).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
        for (final patientId in advice.patientIds) {
          batch.insert(
            AdviceWithPatient.tableName,
            AdviceWithPatient(adviceId: advice.id, patientId: patientId).toMap(),
            conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
          );
        }
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<int> clear() async {
    return await _db.delete(AdviceEntity.tableName);
  }
}
