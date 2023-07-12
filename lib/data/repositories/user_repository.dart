import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class UserRepository {
  /// throws:
  /// - [ApiException] when something goes wrong with [ApiService.login];
  /// the fetched [User];
  Future<void> sync();

  /// throws:
  /// - [DatabaseNotFoundException] when there are no users to retrieve;
  /// database data to a [User] model;
  ///
  /// returns:
  /// - the [User] tied to this account;
  Future<User> get();

  /// Creates remotely an [User] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the [ApiService.signUp];
  ///
  /// returns:
  /// - the created [User];
  Future<User> create(User user);

  /// Clears the table;
  Future<void> clear();
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
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
    await _db.insert(
      UserEntity.tableName,
      UserMapper.toEntity(createdUser).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return createdUser;
  }

  @override
  Future<void> sync() async {
    final user = await _api.login();
    final batch = _db.batch();
    batch.delete(UserEntity.tableName);
    batch.insert(
      UserEntity.tableName,
      UserMapper.toEntity(user).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    await batch.commit(noResult: true);
  }

  @override
  Future<User> get() async {
    final usersMap = await _db.query(UserEntity.tableName);

    if (usersMap.isEmpty) {
      throw const DatabaseNotFoundException(message: "No user found");
    }

    final entity = UserEntity.fromMap(usersMap.first);
    return UserMapper.toUser(entity);
  }

  @override
  Future<void> clear() async {
    await _db.delete(UserEntity.tableName);
  }
}
