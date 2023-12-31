import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/mappers/user_mapper.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:faker/faker.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

class MockApiService extends Mock implements ApiService {}

class MockUser extends Mock implements User {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final UserRepository userRepository;
  final mockUser = MockUser();

  final user = User(
    uid: faker.guid.guid(),
    name: faker.person.name(),
    phoneNumber: faker.phoneNumber.us(),
    isDoctor: true,
  );

  setUpAll(() async {
    registerFallbackValue(user);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi
      ..deleteDatabase(AhpsicoDatabase.dbName);
    database = await AhpsicoDatabase.instance;
    userRepository = UserRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await userRepository.clear();
  });

  group("sync", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.login()).thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await userRepository.sync();
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      when(() => mockApiService.login()).thenAnswer((_) async => user);
      await userRepository.sync();
      final savedUser = await userRepository.get();
      assert(savedUser == user);
    });
  });

  group("get", () {
    test('successful retrieves the user', () async {
      await database.insert(UserEntity.tableName, UserMapper.toEntity(user).toMap());
      final savedUser = await userRepository.get();
      assert(savedUser == user);
    });

    test('no user found throws', () async {
      try {
        await userRepository.get();
        assert(false);
      } on DatabaseNotFoundException catch (_) {
        assert(true);
      }
    });
  });

  group("create", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.signUp(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await userRepository.create(mockUser);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful creation saves to db and returns updated user', () async {
      when(() => mockApiService.signUp(any())).thenAnswer((_) async => user);
      final updatedUser = await userRepository.create(user);
      final savedUser = await userRepository.get();
      assert(savedUser == user);
      assert(updatedUser == user);
    });
  });
}
