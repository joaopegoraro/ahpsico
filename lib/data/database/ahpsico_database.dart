import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/message_entity.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class AhpsicoDatabase {
  static Database? _db;

  @visibleForTesting
  static const dbName = "ahpsico.db";
  static const _dbVersion = 1;

  static const tables = [
    UserEntity.tableName,
    SessionEntity.tableName,
    MessageEntity.tableName,
    AssignmentEntity.tableName,
  ];

  static const _tablesCreationStatements = [
    UserEntity.creationStatement,
    SessionEntity.creationStatement,
    MessageEntity.creationStatement,
    AssignmentEntity.creationStatement,
  ];

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();

    if (_tablesCreationStatements.length != tables.length) {
      throw Exception(
          "Number of table creation statements different than number of tables");
    }

    return await openDatabase(
      join(dbPath, dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        for (final statement in _tablesCreationStatements) {
          await db.execute(statement);
        }
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
