import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/entities/advice_with_patient.dart';
import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class AhpsicoDatabase {
  static Database? _db;

  @visibleForTesting
  static const dbName = "ahpsico.db";
  static const _dbVersion = 1;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute(UserEntity.creationStatement);
        await db.execute(DoctorEntity.creationStatement);
        await db.execute(PatientEntity.creationStatement);
        await db.execute(PatientWithDoctor.creationStatement);
        await db.execute(SessionEntity.creationStatement);
        await db.execute(AdviceEntity.creationStatement);
        await db.execute(AdviceWithPatient.creationStatement);
        await db.execute(AssignmentEntity.creationStatement);
        await db.execute(InviteEntity.creationStatement);
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  static Future<void> closeDatabase() async {
    await _db?.close();
  }
}

/// Needs to be instantiated in the `void main()`, like so:
/// ```dart
///  final database = await AhpsicoDatabase.instance;
///
///  runApp(
///    ProviderScope(
///      overrides: [
///        ahpsicoDatabaseProvider.overrideWithValue(database),
///      ],
///      child: const MyApp(),
///    ),
///  );
///}
/// ```
final ahpsicoDatabaseProvider = Provider<Database>((ref) {
  throw Exception('AhpsicoDatabase Provider was not initialized');
});
