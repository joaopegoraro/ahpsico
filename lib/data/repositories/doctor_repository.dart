import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class DoctorRepository {
  /// Fetches from the API the [Doctor] with the provided [uuid] and saves it in the local
  /// database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> sync(String uuid);

  /// throws:
  /// - [DatabaseNotFoundException] when no [Doctor] was found with the provided [uuid];
  ///
  /// returns:
  /// - the [Doctor] with the requested [uuid];
  Future<Doctor> get(String uuid);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the updated [Doctor];
  Future<Doctor> update(Doctor doctor);

  /// returns:
  /// - the [Doctor] list of the [Patient] with [patientId];
  Future<List<Doctor>> getPatientDoctors(String patientId);

  /// Fetches from the API the [Doctor] list from the [Patient] with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> syncPatientDoctors(String doctorId);

  /// Clears the table;
  Future<void> clear();
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
    await _db.insert(
      DoctorEntity.tableName,
      DoctorMapper.toEntity(doctor).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
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

    final doctorEntity = DoctorEntity.fromMap(doctorMap.first);
    final doctor = DoctorMapper.toDoctor(doctorEntity);
    return doctor;
  }

  @override
  Future<Doctor> update(Doctor doctor) async {
    final updatedDoctor = await _api.updateDoctor(doctor);

    await _db.insert(
      DoctorEntity.tableName,
      DoctorMapper.toEntity(updatedDoctor).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return updatedDoctor;
  }

  @override
  Future<List<Doctor>> getPatientDoctors(String patientId) async {
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
  }

  @override
  Future<void> syncPatientDoctors(String patientId) async {
    final doctors = await _api.getPatientDoctors(patientId);
    final batch = _db.batch();

    batch.rawDelete(
      """
        DELETE FROM ${DoctorEntity.tableName} WHERE ${DoctorEntity.uuidColumn} in (
          SELECT ${DoctorEntity.uuidColumn} FROM ${DoctorEntity.tableName} d  
            LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.doctorIdColumn} = d.${DoctorEntity.uuidColumn}  
            WHERE pd.${PatientWithDoctor.patientIdColumn} = ?)
        """,
      [patientId],
    );

    for (final doctor in doctors) {
      batch.insert(
        DoctorEntity.tableName,
        DoctorMapper.toEntity(doctor).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      batch.insert(
        PatientWithDoctor.tableName,
        PatientWithDoctor(patientId: patientId, doctorId: doctor.uuid).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clear() async {
    await _db.delete(DoctorEntity.tableName);
  }
}
