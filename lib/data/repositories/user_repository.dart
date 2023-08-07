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
  Future<ApiException?> sync(String uuid);

  Future<User> get(String uuid);

  Future<(User?, ApiException?)> create(String userName, UserRole role);

  Future<(User?, ApiException?)> update(User user);

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
  Future<(User?, ApiException?)> create(String userName, UserRole role) async {
    final (createdUser, err) = await _api.signUp(userName, role);
    if (err != null) return (null, err);
    await _db.insert(
      UserEntity.tableName,
      UserMapper.toEntity(createdUser!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return (createdUser, null);
  }

  @override
  Future<(User?, ApiException?)> update(User user) async {
    final (updatedUser, err) = await _api.updateUser(user);
    if (err != null) return (null, err);
    await _db.insert(
      UserEntity.tableName,
      UserMapper.toEntity(updatedUser!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    return (updatedUser, null);
  }

  @override
  Future<ApiException?> sync(String uuid) async {
    final (user, err) = await _api.getUser(uuid);
    if (err != null) return err;

    final batch = _db.batch();
    batch.delete(UserEntity.tableName);
    batch.insert(
      UserEntity.tableName,
      UserMapper.toEntity(user!).toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
    await batch.commit(noResult: true);

    return null;
  }

  @override
  Future<User> get(String uuid) async {
    final usersMap = await _db.query(
      UserEntity.tableName,
      where: "${UserEntity.uuidColumn} = ?",
      whereArgs: [uuid],
    );

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
