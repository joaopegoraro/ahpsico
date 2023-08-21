import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/utils/extensions.dart';
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
        SELECT * FROM ${UserEntity.tableName} WHERE ${UserEntity.roleColumn} = ?
      """,
      [UserRole.doctor.value],
    );

    return doctorsMap.mapToList((e) {
      final entity = UserEntity.fromMap(e);
      return UserMapper.toUser(entity);
    });
  }

  @override
  Future<ApiError?> syncPatientDoctors(String patientId) async {
    final (doctors, err) = await _api.getPatientDoctors(patientId);
    if (err != null) return err;

    final batch = _db.batch();
    batch.rawDelete(
      """
        DELETE FROM ${UserEntity.tableName} WHERE ${UserEntity.roleColumn} = ?
      """,
      [UserRole.doctor.value],
    );

    for (final doctor in doctors!) {
      batch.insert(
        UserEntity.tableName,
        UserMapper.toEntity(doctor).toMap(),
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
