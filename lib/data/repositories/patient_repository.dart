import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class PatientRepository {
  /// Fetches from the API the [Patient] with the provided [uuid] and saves it in the local
  /// database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> sync(String uuid);

  /// throws:
  /// - [DatabaseNotFoundException] when no [Patient] was found with the provided [uuid];
  ///
  /// returns:
  /// - the [Patient] with the requested [uuid];
  Future<Patient> get(String uuid);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the updated [Patient];
  Future<Patient> update(Patient patient);

  /// returns:
  /// - the [Patient] list of the [Doctor] with [doctorId];
  Future<List<Patient>> getDoctorPatients(String doctorId);

  /// Fetches from the API the [Patient] list from the [Doctor] with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> syncDoctorPatients(String doctorId);

  /// Clears the table;
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
    await _db.insert(
      PatientEntity.tableName,
      PatientMapper.toEntity(patient).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
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

    final patientEntity = PatientEntity.fromMap(patientMap.first);
    final patient = PatientMapper.toPatient(patientEntity);
    return patient;
  }

  @override
  Future<Patient> update(Patient patient) async {
    final updatedPatient = await _api.updatePatient(patient);

    await _db.insert(
      PatientEntity.tableName,
      PatientMapper.toEntity(updatedPatient).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return updatedPatient;
  }

  @override
  Future<List<Patient>> getDoctorPatients(String doctorId) async {
    final patientsMap = await _db.rawQuery(
      """
        SELECT d.* FROM ${PatientEntity.tableName} d  
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
  }

  @override
  Future<void> syncDoctorPatients(String doctorId) async {
    final patients = await _api.getDoctorPatients(doctorId);
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
  }

  @override
  Future<void> clear() async {
    await _db.delete(PatientEntity.tableName);
  }
}
