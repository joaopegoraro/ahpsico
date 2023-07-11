import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class PatientRepository {
  /// Fetches from the API the [Patient] with the provided [uuid] and saves it in the local
  /// database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> sync(String uuid);

  /// throws:
  /// - [DatabaseNotFoundException] when no [Patient] was found with the provided [uuid];
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a [Patient] model;
  ///
  /// returns:
  /// - the [Patient] with the requested [uuid];
  Future<Patient> get(String uuid);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote updating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  ///
  /// returns:
  /// - the updated [Patient];
  Future<Patient> update(Patient patient);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Patient] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Patient] models;
  ///
  /// returns:
  /// - the [Patient] list of the [Doctor] with [doctorId];
  Future<List<Patient>> getDoctorPatients(String doctorId);

  /// Fetches from the API the [Patient] list from the [Doctor] with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncDoctorPatients(String doctorId);

  /// Clears the table;
  ///
  /// throws:
  /// - [DatabaseInsertException] when something goes wrong when deleting the data;
  Future<void> clear();
}

final patientRepositoryProvider = Provider((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return PatientRepositoryImpl(apiService: apiService, database: database);
});

final class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<void> sync(String uuid) async {
    final patient = await _api.getPatient(uuid);
    try {
      await _db.insert(
        PatientEntity.tableName,
        PatientMapper.toEntity(patient).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Patient> get(String uuid) async {
    final patientMap = await _db.query(
      PatientEntity.tableName,
      where: "${PatientEntity.uuidColumn} = ?",
      whereArgs: [uuid],
    );

    if (patientMap.isEmpty) {
      throw DatabaseNotFoundException(message: "Patient with id $uuid not found");
    }

    try {
      final patientEntity = PatientEntity.fromMap(patientMap.first);
      final patient = PatientMapper.toPatient(patientEntity);
      return patient;
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Patient> update(Patient patient) async {
    final updatedPatient = await _api.updatePatient(patient);

    try {
      await _db.insert(
        PatientEntity.tableName,
        PatientMapper.toEntity(updatedPatient).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );

      return updatedPatient;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Patient>> getDoctorPatients(String doctorId) async {
    try {
      final patientsMap = await _db.rawQuery(
        """
        SELECT * FROM ${PatientEntity.tableName} d  
          LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.patientIdColumn} = d.${PatientEntity.uuidColumn}  
          WHERE pd.${PatientWithDoctor.doctorIdColumn} = ?
        """,
        [doctorId],
      );

      final patients = patientsMap.map((e) {
        final entity = PatientEntity.fromMap(e);
        return PatientMapper.toPatient(entity);
      });
      return patients.toList();
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncDoctorPatients(String doctorId) async {
    final patients = await _api.getDoctorPatients(doctorId);
    try {
      final batch = _db.batch();

      batch.rawDelete(
        """
        DELETE FROM ${PatientEntity.tableName} WHERE ${PatientEntity.uuidColumn} in (
          SELECT ${PatientEntity.uuidColumn} FROM ${PatientEntity.tableName} d  
            LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.patientIdColumn} = d.${PatientEntity.uuidColumn}  
            WHERE pd.${PatientWithDoctor.doctorIdColumn} = ?)
        """,
        [doctorId],
      );

      for (final patient in patients) {
        batch.insert(
          PatientEntity.tableName,
          PatientMapper.toEntity(patient).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
        batch.insert(
          PatientWithDoctor.tableName,
          PatientWithDoctor(patientId: patient.uuid, doctorId: doctorId).toMap(),
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
    await _db.delete(PatientEntity.tableName);
  }
}
