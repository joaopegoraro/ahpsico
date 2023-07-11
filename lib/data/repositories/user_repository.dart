import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class UserRepository {
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting
  /// the fetched [User];
  Future<void> sync();

  /// throws:
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a [User] model;
  ///
  /// returns:
  /// - the [User] tied to this account;
  Future<User> get();

  /// Creates remotely an [User] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the new [User];
  ///
  /// returns:
  /// - the created [User];
  Future<User> create(User user);
}

final userRepositoryProvider = Provider((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(ahpsicoDatabaseProvider);
  return UserRepositoryImpl(apiService: apiService, database: database);
});

final class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required ApiService apiService,
    required sqflite.Database database,
  })  : _api = apiService,
        _db = database;

  final ApiService _api;
  final sqflite.Database _db;

  @override
  Future<User> create(User user) async {
    final createdUser = await _api.signUp(user);
    try {
      await _db.insert(
        UserEntity.tableName,
        UserMapper.toEntity(createdUser).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
    return createdUser;
  }

  @override
  Future<void> sync() async {
    final user = await _api.login();
    try {
      final batch = _db.batch();
      batch.delete(UserEntity.tableName);
      batch.insert(
        UserEntity.tableName,
        UserMapper.toEntity(user).toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
      await batch.commit(noResult: true);
    } on sqflite.DatabaseException catch (e, stackTrace) {
      DatabaseInsertException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }

  @override
  Future<User> get() async {
    final usersMap = await _db.query(UserEntity.tableName);
    try {
      final entity = UserEntity.fromMap(usersMap.first);
      return UserMapper.toUser(entity);
    } on TypeError catch (e, stackTrace) {
      DatabaseMappingException(message: e.toString()).throwWithStackTrace(stackTrace);
    }
  }
}
