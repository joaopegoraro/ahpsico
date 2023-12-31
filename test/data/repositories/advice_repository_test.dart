import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/advice_with_patient.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/advice_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/data/database/mappers/advice_mapper.dart';
import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

class MockApiService extends Mock implements ApiService {}

class MockAdvice extends Mock implements Advice {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final AdviceRepository adviceRepository;
  final mockAdvice = MockAdvice();

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

  final advice = Advice(
    id: 0,
    doctor: doctor,
    patientIds: [patient.uuid],
    message: faker.lorem.sentence(),
  );

  setUpAll(() async {
    registerFallbackValue(advice);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi
      ..deleteDatabase(AhpsicoDatabase.dbName);

    database = await AhpsicoDatabase.instance;
    adviceRepository = AdviceRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await adviceRepository.clear();
    await database.delete(DoctorEntity.tableName);
    await database.delete(PatientEntity.tableName);
    await database.delete(AdviceWithPatient.tableName);
  });

  group("create", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.createAdvice(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await adviceRepository.create(mockAdvice);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful updates saves to db and returns updated advice', () async {
      when(() => mockApiService.createAdvice(any())).thenAnswer((_) async => advice);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      final updatedAdvice = await adviceRepository.create(advice);
      final savedAdviceMap = await database.query(
        AdviceEntity.tableName,
        where: "${AdviceEntity.idColumn} = ?",
        whereArgs: [advice.id],
      );
      final savedAdvice = AdviceMapper.toAdvice(
        AdviceEntity.fromMap(savedAdviceMap.first),
        doctorEntity: DoctorMapper.toEntity(doctor),
        patientIds: [patient.uuid],
      );
      assert(savedAdvice == advice);
      assert(updatedAdvice == advice);
    });
  });

  group("update", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.updateAdvice(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await adviceRepository.update(mockAdvice);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful updates saves to db and returns updated advice', () async {
      when(() => mockApiService.updateAdvice(any())).thenAnswer((_) async => advice);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      final updatedAdvice = await adviceRepository.update(advice);
      final savedAdviceMap = await database.query(
        AdviceEntity.tableName,
        where: "${AdviceEntity.idColumn} = ?",
        whereArgs: [advice.id],
      );
      final savedAdvice = AdviceMapper.toAdvice(
        AdviceEntity.fromMap(savedAdviceMap.first),
        doctorEntity: DoctorMapper.toEntity(doctor),
        patientIds: [patient.uuid],
      );
      assert(savedAdvice == advice);
      assert(updatedAdvice == advice);
    });
  });

  group("delete", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.deleteAdvice(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await adviceRepository.delete(advice.id);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful delete removes from db', () async {
      when(() => mockApiService.deleteAdvice(any())).thenAnswer((_) async {});
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      assert(
        await database.insert(AdviceEntity.tableName, AdviceMapper.toEntity(advice).toMap()) ==
            advice.id,
      );
      await adviceRepository.delete(advice.id);
      final savedAdvicesMap = await database.query(
        AdviceEntity.tableName,
        where: "${AdviceEntity.idColumn} = ?",
        whereArgs: [advice.id],
      );
      assert(savedAdvicesMap.isEmpty);
    });
  });

  group("syncDoctorAdvices", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getDoctorAdvices(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await adviceRepository.syncDoctorAdvices('some id');
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      final expectedList = [advice];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getDoctorAdvices(any())).thenAnswer((_) async => expectedList);
      await adviceRepository.syncDoctorAdvices(doctor.uuid);
      final savedAdvices = await adviceRepository.getDoctorAdvices(doctor.uuid);
      assert(const ListEquality().equals(savedAdvices, expectedList));
    });
  });

  group("getDoctorAdvices", () {
    test('successful fetch returns advice list', () async {
      final expectedList = [advice];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getDoctorAdvices(any())).thenAnswer((_) async => expectedList);
      await adviceRepository.syncDoctorAdvices(doctor.uuid);
      final savedAdvices = await adviceRepository.getDoctorAdvices(doctor.uuid);
      assert(const ListEquality().equals(savedAdvices, expectedList));
    });

    test('empty table returns empty list', () async {
      final savedAdvices = await adviceRepository.getDoctorAdvices(doctor.uuid);
      assert(savedAdvices.isEmpty);
    });
  });

  group("syncPatientAdvices", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getPatientAdvices(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await adviceRepository.syncPatientAdvices('some id');
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      final expectedList = [advice];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getPatientAdvices(any())).thenAnswer((_) async => expectedList);
      await adviceRepository.syncPatientAdvices(patient.uuid);
      final savedAdvices = await adviceRepository.getPatientAdvices(patient.uuid);
      assert(const ListEquality().equals(savedAdvices, expectedList));
    });
  });

  group("getPatientAdvices", () {
    test('successful fetch returns advice list', () async {
      final savedAdvices = await adviceRepository.getPatientAdvices(patient.uuid);
      assert(savedAdvices.isEmpty);
    });
  });
}
