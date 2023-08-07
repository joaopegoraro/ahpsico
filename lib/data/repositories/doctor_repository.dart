import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class DoctorRepository {
  /// returns:
  /// - the doctor list of the patient with [patientId];
  Future<List<User>> getPatientDoctors(String patientId);

  /// Fetches from the API the doctor list from the patient with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> syncPatientDoctors(String doctorId);

  /// Clears the table;
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
  Future<void> syncPatientDoctors(String patientId) async {
    final doctors = await _api.getPatientDoctors(patientId);
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

    for (final doctor in doctors) {
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
  }

  @override
  Future<void> clear() async {
    await _db.delete(UserEntity.tableName);
  }
}
