import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/data/repositories/doctor_repository.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

class MockApiService extends Mock implements ApiService {}

class MockDoctor extends Mock implements Doctor {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final DoctorRepository doctorRepository;
  final mockDoctor = MockDoctor();

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

  setUpAll(() async {
    registerFallbackValue(doctor);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi
      ..deleteDatabase(AhpsicoDatabase.dbName);
    database = await AhpsicoDatabase.instance;
    doctorRepository = DoctorRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await doctorRepository.clear();
    await database.delete(PatientEntity.tableName);
    await database.delete(PatientWithDoctor.tableName);
  });

  group("sync", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getDoctor(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await doctorRepository.sync('some id');
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      when(() => mockApiService.getDoctor(any())).thenAnswer((_) async => doctor);
      await doctorRepository.sync('some id');
      final savedDoctor = await doctorRepository.get(doctor.uuid);
      assert(savedDoctor == doctor);
    });
  });

  group("get", () {
    test('successful retrieves the doctor', () async {
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      final savedDoctor = await doctorRepository.get(doctor.uuid);
      assert(savedDoctor == doctor);
    });

    test('no doctor found throws', () async {
      try {
        await doctorRepository.get(doctor.uuid);
        assert(false);
      } on DatabaseNotFoundException catch (_) {
        assert(true);
      }
    });
  });

  group("update", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.updateDoctor(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await doctorRepository.update(mockDoctor);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful updates saves to db and returns updated doctor', () async {
      when(() => mockApiService.updateDoctor(any())).thenAnswer((_) async => doctor);
      final updatedDoctor = await doctorRepository.update(doctor);
      final savedDoctor = await doctorRepository.get(doctor.uuid);
      assert(savedDoctor == doctor);
      assert(updatedDoctor == doctor);
    });
  });

  group("syncPatientDoctors", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getPatientDoctors(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await doctorRepository.syncPatientDoctors('some id');
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });
    test('successful sync saves to db', () async {
      final expectedList = [doctor];
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getPatientDoctors(any())).thenAnswer((_) async => expectedList);
      await doctorRepository.syncPatientDoctors(patient.uuid);
      final savedDoctors = await doctorRepository.getPatientDoctors(patient.uuid);
      assert(const ListEquality().equals(savedDoctors, expectedList));
    });
  });

  group("getPatientDoctors", () {
    test('successful fetch returns doctor list', () async {
      final expectedList = [doctor];
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getPatientDoctors(any())).thenAnswer((_) async => expectedList);
      await doctorRepository.syncPatientDoctors(patient.uuid);
      final savedDoctors = await doctorRepository.getPatientDoctors(patient.uuid);
      assert(const ListEquality().equals(savedDoctors, expectedList));
    });
    test('empty table returns empty list', () async {
      final savedDoctors = await doctorRepository.getPatientDoctors(patient.uuid);
      assert(savedDoctors.isEmpty);
    });
  });
}
