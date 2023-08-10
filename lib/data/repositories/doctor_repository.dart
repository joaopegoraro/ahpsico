import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class DoctorRepository {
  Future<List<User>> getPatientDoctors(String patientId);

  Future<ApiError?> syncPatientDoctors(String patientId);

  Future<void> clear();
}

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
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
  Future<List<User>> getPatientDoctors(String patientId) async {
    final doctorsMap = await _db.rawQuery(
      """
        SELECT * FROM ${UserEntity.tableName} d  
          LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.doctorIdColumn} = d.${UserEntity.uuidColumn}  
          WHERE pd.${PatientWithDoctor.patientIdColumn} = ?
        """,
      [patientId],
    );

    final doctors = doctorsMap.map((e) {
      final entity = UserEntity.fromMap(e);
      return UserMapper.toUser(entity);
    });

    return doctors.toList();
  }

  @override
  Future<ApiError?> syncPatientDoctors(String patientId) async {
    final (doctors, err) = await _api.getPatientDoctors(patientId);
    if (err != null) return err;

    final batch = _db.batch();
    batch.rawDelete(
      """
        DELETE FROM ${UserEntity.tableName} WHERE ${UserEntity.uuidColumn} in (
          SELECT ${UserEntity.uuidColumn} FROM ${UserEntity.tableName} d  
            LEFT JOIN ${PatientWithDoctor.tableName} pd ON pd.${PatientWithDoctor.doctorIdColumn} = d.${UserEntity.uuidColumn}  
            WHERE pd.${PatientWithDoctor.patientIdColumn} = ?)
        """,
      [patientId],
    );

    for (final doctor in doctors!) {
      batch.insert(
        UserEntity.tableName,
        UserMapper.toEntity(doctor).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      batch.insert(
        PatientWithDoctor.tableName,
        PatientWithDoctor(patientId: patientId, doctorId: doctor.uuid).toMap(),
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
