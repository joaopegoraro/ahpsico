import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/entities/advice_with_patient.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/mappers/advice_mapper.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite/sqlite_api.dart';

abstract interface class AdviceRepository {
  Future<(Advice?, ApiError?)> create(Advice advice);

  Future<ApiError?> delete(int id);

  Future<List<Advice>> getPatientAdvices(String patientId);

  Future<ApiError?> syncPatientAdvices(String patientId);

  Future<List<Advice>> getDoctorAdvices(String doctorId);

  Future<ApiError?> syncDoctorAdvices(String doctorId);

  Future<int> clear();
}

final adviceRepositoryProvider = Provider<AdviceRepository>((ref) {
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
  Future<(Advice?, ApiError?)> create(Advice advice) async {
    final (createdAdvice, err) = await _api.createAdvice(advice);
    if (err != null) return (createdAdvice, err);
    await _db.insert(
      AdviceEntity.tableName,
      AdviceMapper.toEntity(createdAdvice!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return (createdAdvice, null);
  }

  @override
  Future<ApiError?> delete(int id) async {
    final err = await _api.deleteAdvice(id);
    if (err != null) return err;
    await _deleteLocally(id);
    return null;
  }

  @override
  Future<List<Advice>> getPatientAdvices(String patientId) async {
    final advicesMap = await _db.rawQuery(
      """
        SELECT a.* FROM ${AdviceEntity.tableName} a  
          LEFT JOIN ${AdviceWithPatient.tableName} ap ON ap.${AdviceWithPatient.adviceIdColumn} = a.${AdviceEntity.idColumn}  
          WHERE ap.${AdviceWithPatient.patientIdColumn} = ?
        """,
      [patientId],
    );

    final advices = <Advice>[];
    for (final adviceMap in advicesMap) {
      final entity = AdviceEntity.fromMap(adviceMap);

      final doctorsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [entity.doctorId],
      );
      if (doctorsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final doctorEntity = UserEntity.fromMap(doctorsMap.firstOrNull ?? {"uuid": entity.doctorId});

      final patientsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [patientId],
      );
      if (patientsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final patientIds = patientsMap.mapToList((patient) {
        final patientEntity = UserEntity.fromMap(patient);
        return patientEntity.uuid;
      });

      advices.add(AdviceMapper.toAdvice(
        entity,
        doctorEntity: doctorEntity,
        patientIds: patientIds,
      ));
    }

    return advices;
  }

  @override
  Future<ApiError?> syncPatientAdvices(String patientId) async {
    final (advices, err) = await _api.getPatientAdvices(patientId);
    if (err != null) return err;

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

    for (final advice in advices!) {
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

    try {
      await batch.commit(noResult: true);
    } on DatabaseException catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }

    return null;
  }

  @override
  Future<List<Advice>> getDoctorAdvices(String doctorId) async {
    final advicesMap = await _db.query(
      AdviceEntity.tableName,
      where: "${AdviceEntity.doctorIdColumn} = ?",
      whereArgs: [doctorId],
    );

    final advices = <Advice>[];
    for (final adviceMap in advicesMap) {
      final entity = AdviceEntity.fromMap(adviceMap);

      final doctorsMap = await _db.query(
        UserEntity.tableName,
        where: "${UserEntity.uuidColumn} = ?",
        whereArgs: [doctorId],
      );
      if (doctorsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final doctorEntity = UserEntity.fromMap(doctorsMap.first);

      final patientsMap = await _db.rawQuery(
        """
          SELECT  p.* FROM ${UserEntity.tableName} p  
            LEFT JOIN ${AdviceWithPatient.tableName} ad ON ad.${AdviceWithPatient.patientIdColumn} = p.${UserEntity.uuidColumn}  
            WHERE ad.${AdviceWithPatient.adviceIdColumn} = ?
          """,
        [entity.id],
      );
      if (patientsMap.isEmpty) {
        await _deleteLocally(entity.id);
        continue;
      }
      final patientIds = patientsMap.mapToList((patient) {
        final patientEntity = UserEntity.fromMap(patient);
        return patientEntity.uuid;
      });

      advices.add(AdviceMapper.toAdvice(
        entity,
        doctorEntity: doctorEntity,
        patientIds: patientIds,
      ));
    }

    return advices;
  }

  @override
  Future<ApiError?> syncDoctorAdvices(String doctorId) async {
    final (advices, err) = await _api.getDoctorAdvices(doctorId);
    if (err != null) return err;

    final batch = _db.batch();

    batch.delete(
      AdviceEntity.tableName,
      where: "${AdviceEntity.doctorIdColumn} = ?",
      whereArgs: [doctorId],
    );

    for (final advice in advices!) {
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

    return null;
  }

  @override
  Future<int> clear() async {
    return await _db.delete(AdviceEntity.tableName);
  }

  Future<void> _deleteLocally(int id) async {
    await _db.delete(
      AdviceEntity.tableName,
      where: "${AdviceEntity.idColumn} = ?",
      whereArgs: [id],
    );
  }
}
