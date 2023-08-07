import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class PatientRepository {
  Future<List<User>> getDoctorPatients(String doctorId);

  Future<ApiError?> syncDoctorPatients(String doctorId);

  Future<void> clear();
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
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
  Future<List<User>> getDoctorPatients(String doctorId) async {
    final patientsMap = await _db.rawQuery(
      """
        SELECT d.* FROM ${UserEntity.tableName} d  
          LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.patientIdColumn} = d.${UserEntity.uuidColumn}  
          WHERE pd.${PatientWithDoctor.doctorIdColumn} = ?
        """,
      [doctorId],
    );

    final patients = patientsMap.map((e) {
      final entity = UserEntity.fromMap(e);
      return UserMapper.toUser(entity);
    });
    return patients.toList();
  }

  @override
  Future<ApiError?> syncDoctorPatients(String doctorId) async {
    final (patients, err) = await _api.getDoctorPatients(doctorId);
    if (err != null) return err;

    final batch = _db.batch();

    batch.rawDelete(
      """
        DELETE FROM ${UserEntity.tableName} WHERE ${UserEntity.uuidColumn} in (
          SELECT ${UserEntity.uuidColumn} FROM ${UserEntity.tableName} d  
            LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.patientIdColumn} = d.${UserEntity.uuidColumn}  
            WHERE pd.${PatientWithDoctor.doctorIdColumn} = ?)
        """,
      [doctorId],
    );

    for (final patient in patients!) {
      batch.insert(
        UserEntity.tableName,
        UserMapper.toEntity(patient).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      batch.insert(
        PatientWithDoctor.tableName,
        PatientWithDoctor(patientId: patient.uuid, doctorId: doctorId).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<void> clear() async {
    await _db.delete(UserEntity.tableName);
  }
}
