import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class DoctorRepository {
  /// Fetches from the API the [Doctor] with the provided [uuid] and saves it in the local
  /// database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> sync(String uuid);

  /// throws:
  /// - [DatabaseNotFoundException] when no [Doctor] was found with the provided [uuid];
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a [Doctor] model;
  ///
  /// returns:
  /// - the [Doctor] with the requested [uuid];
  Future<Doctor> get(String uuid);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote updating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  ///
  /// returns:
  /// - the updated [Doctor];
  Future<Doctor> update(Doctor doctor);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Doctor] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Doctor] models;
  ///
  /// returns:
  /// - the [Doctor] list of the [Patient] with [patientId];
  Future<List<Doctor>> getPatientDoctors(String patientId);

  /// Fetches from the API the [Doctor] list from the [Patient] with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncPatientDoctors(String doctorId);
}

final doctorRepositoryProvider = Provider((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return DoctorRepositoryImpl(apiService: apiService, database: database);
});

final class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<void> sync(String uuid) async {
    final doctor = await _api.getDoctor(uuid);
    try {
      await _db.insert(
        DoctorEntity.tableName,
        DoctorMapper.toEntity(doctor).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Doctor> get(String uuid) async {
    final doctorMap = await _db.query(
      DoctorEntity.tableName,
      where: "${DoctorEntity.uuidColumn} = ?",
      whereArgs: [uuid],
    );

    if (doctorMap.isEmpty) {
      throw DatabaseNotFoundException(message: "Doctor with id $uuid not found");
    }

    try {
      final doctorEntity = DoctorEntity.fromMap(doctorMap.first);
      final doctor = DoctorMapper.toDoctor(doctorEntity);
      return doctor;
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<Doctor> update(Doctor doctor) async {
    final updatedDoctor = await _api.updateDoctor(doctor);

    try {
      await _db.insert(
        DoctorEntity.tableName,
        DoctorMapper.toEntity(updatedDoctor).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );

      return updatedDoctor;
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<List<Doctor>> getPatientDoctors(String patientId) async {
    try {
      final doctorsMap = await _db.rawQuery(
        """
        SELECT * FROM ${DoctorEntity.tableName} d  
          LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.doctorIdColumn} = d.${DoctorEntity.uuidColumn}  
          WHERE pd.${PatientWithDoctor.patientIdColumn} = ?
        """,
        [patientId],
      );

      final doctors = doctorsMap.map((e) {
        final entity = DoctorEntity.fromMap(e);
        return DoctorMapper.toDoctor(entity);
      });
      return doctors.toList();
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseNotFoundException(message: e.toString()).throwWithStackTrace(stackTrace);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<void> syncPatientDoctors(String patientId) async {
    final doctors = await _api.getPatientDoctors(patientId);
    try {
      final batch = _db.batch();

      batch.rawDelete(
        """
        DELETE FROM ${DoctorEntity.tableName} d  
          LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.doctorIdColumn} = d.${DoctorEntity.uuidColumn}  
          WHERE pd.${PatientWithDoctor.patientIdColumn} = ?
        """,
        [patientId],
      );

      for (final doctor in doctors) {
        batch.insert(
          DoctorEntity.tableName,
          doctor.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
        batch.insert(
          PatientWithDoctor.tableName,
          PatientWithDoctor(patientId: patientId, doctorId: doctor.uuid).toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }
}
