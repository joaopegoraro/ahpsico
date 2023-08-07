import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

abstract interface class UserRepository {
  /// throws:
  /// - [ApiUserNotRegisteredException] when the user trying to login is
  /// not yet registered.
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  /// the fetched [User];
  Future<void> sync(String uuid);

  /// throws:
  /// - [DatabaseNotFoundException] when there are no users to retrieve;
  ///
  /// returns:
  /// - the [User] tied to this account;
  Future<User> get();

  /// Creates remotely an [User] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiUserAlreadyRegisteredException] when the user trying to sign up is
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the created [User];
  Future<User> create(String userName, UserRole role);

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
  Future<User> create(String userName, UserRole role) async {
    final createdUser = await _api.signUp(userName, role);
    await _db.insert(
      UserEntity.tableName,
      UserMapper.toEntity(createdUser).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return createdUser;
  }

  @override
  Future<void> sync(String uuid) async {
    final user = await _api.getUser(uuid);
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
