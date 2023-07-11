import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/invite_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/data/database/mappers/invite_mapper.dart';
import 'package:ahpsico/data/repositories/invite_repository.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

class MockApiService extends Mock implements ApiService {}

class MockInvite extends Mock implements Invite {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final InviteRepository inviteRepository;
  final mockInvite = MockInvite();

  final doctor = Doctor(
    uuid: faker.guid.guid(),
    name: faker.person.name(),
    phoneNumber: faker.phoneNumber.us(),
    description: faker.lorem.sentence(),
    crp: faker.phoneNumber.de(),
    pixKey: faker.internet.email(),
    paymentDetails: faker.company.name(),
  );

  final patient = Patient(
    uuid: faker.guid.guid(),
    name: faker.person.name(),
    phoneNumber: faker.phoneNumber.us(),
  );

  final invite = Invite(
    id: 0,
    doctor: doctor,
    patientId: patient.uuid,
    phoneNumber: patient.phoneNumber,
  );

  setUpAll(() async {
    registerFallbackValue(invite);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi..deleteDatabase(AhpsicoDatabase.dbName);
    database = await AhpsicoDatabase.instance;
    inviteRepository = InviteRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await inviteRepository.clear();
    await database.delete(DoctorEntity.tableName);
    await database.delete(PatientEntity.tableName);
    await database.delete(SessionEntity.tableName);
  });

  group("create", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.createInvite(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await inviteRepository.create(invite.phoneNumber);
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('successful creates saves to db and returns updated invite', () async {
      when(() => mockApiService.createInvite(any())).thenAnswer((_) async => invite);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      final updatedInvite = await inviteRepository.create(invite.phoneNumber);
      final savedInviteMap = await database.query(
        InviteEntity.tableName,
        where: "${InviteEntity.idColumn} = ?",
        whereArgs: [invite.id],
      );
      final savedInvite = InviteMapper.toInvite(
        InviteEntity.fromMap(savedInviteMap.first),
        doctorEntity: DoctorMapper.toEntity(doctor),
      );
      assert(savedInvite == invite);
      assert(updatedInvite == invite);
    });
  });

  group("delete", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.deleteInvite(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await inviteRepository.delete(invite.id);
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('db error throws', () async {
      when(() => mockApiService.deleteInvite(any())).thenAnswer((_) async {});
      when(() => mockInvite.id).thenThrow(const DatabaseInsertException());
      try {
        await inviteRepository.delete(mockInvite.id);
        assert(false);
      } on DatabaseInsertException catch (_) {
        assert(true);
      }
    });

    test('successful delete removes from db', () async {
      when(() => mockApiService.deleteInvite(any())).thenAnswer((_) async {});
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      assert(
        await database.insert(InviteEntity.tableName, InviteMapper.toEntity(invite).toMap()) == invite.id,
      );
      await inviteRepository.delete(invite.id);
      final savedInviteMap = await database.query(
        InviteEntity.tableName,
        where: "${InviteEntity.idColumn} = ?",
        whereArgs: [invite.id],
      );
      assert(savedInviteMap.isEmpty);
    });
  });

  group("accept", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.acceptInvite(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await inviteRepository.accept(invite.id);
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('db error throws', () async {
      when(() => mockApiService.acceptInvite(any())).thenAnswer((_) async {});
      when(() => mockInvite.id).thenThrow(const DatabaseInsertException());
      try {
        await inviteRepository.accept(mockInvite.id);
        assert(false);
      } on DatabaseInsertException catch (_) {
        assert(true);
      }
    });

    test('successful delete removes from db', () async {
      when(() => mockApiService.acceptInvite(any())).thenAnswer((_) async {});
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      assert(
        await database.insert(InviteEntity.tableName, InviteMapper.toEntity(invite).toMap()) == invite.id,
      );
      await inviteRepository.accept(invite.id);
      final savedInviteMap = await database.query(
        InviteEntity.tableName,
        where: "${InviteEntity.idColumn} = ?",
        whereArgs: [invite.id],
      );
      assert(savedInviteMap.isEmpty);
    });
  });

  group("sync", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getInvites()).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await inviteRepository.sync();
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('db error throws', () async {
      when(() => mockApiService.getInvites()).thenAnswer((_) async => [mockInvite]);
      when(() => mockInvite.id).thenThrow(const DatabaseInsertException());
      try {
        await inviteRepository.sync();
        assert(false);
      } on DatabaseInsertException catch (_) {
        assert(true);
      }
    });

    test('successful sync saves to db', () async {
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      final expectedList = [invite];
      when(() => mockApiService.getInvites()).thenAnswer((_) async => expectedList);
      await inviteRepository.sync();
      final savedInvites = await inviteRepository.get();
      assert(const ListEquality().equals(expectedList, savedInvites));
    });
  });

  group("get", () {
    test('successful retrieves the patient', () async {
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(InviteEntity.tableName, InviteMapper.toEntity(invite).toMap());
      final savedInvites = await inviteRepository.get();
      assert(const ListEquality().equals([invite], savedInvites));
    });

    test('no patient found throws', () async {
      try {
        await inviteRepository.get();
        assert(false);
      } on DatabaseNotFoundException catch (_) {
        assert(true);
      }
    });
  });
}