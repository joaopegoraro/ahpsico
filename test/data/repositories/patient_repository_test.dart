import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/patient_with_doctor.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/data/repositories/patient_repository.dart';
import 'package:ahpsico/models/doctor.dart';
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

class MockPatient extends Mock implements Patient {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final PatientRepository patientRepository;
  final mockPatient = MockPatient();

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
    registerFallbackValue(patient);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi..deleteDatabase(AhpsicoDatabase.dbName);
    database = await AhpsicoDatabase.instance;
    patientRepository = PatientRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await patientRepository.clear();
    await database.delete(DoctorEntity.tableName);
    await database.delete(PatientWithDoctor.tableName);
  });

  group("sync", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getPatient(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await patientRepository.sync('some id');
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      when(() => mockApiService.getPatient(any())).thenAnswer((_) async => patient);
      await patientRepository.sync('some id');
      final savedPatient = await patientRepository.get(patient.uuid);
      assert(savedPatient == patient);
    });
  });

  group("get", () {
    test('successful retrieves the patient', () async {
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      final savedPatient = await patientRepository.get(patient.uuid);
      assert(savedPatient == patient);
    });

    test('no patient found throws', () async {
      try {
        await patientRepository.get(patient.uuid);
        assert(false);
      } on DatabaseNotFoundException catch (_) {
        assert(true);
      }
    });
  });

  group("update", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.updatePatient(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await patientRepository.update(mockPatient);
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('successful updates saves to db and returns updated patient', () async {
      when(() => mockApiService.updatePatient(any())).thenAnswer((_) async => patient);
      final updatedPatient = await patientRepository.update(patient);
      final savedPatient = await patientRepository.get(patient.uuid);
      assert(savedPatient == patient);
      assert(updatedPatient == patient);
    });
  });

  group("syncDoctorPatients", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getDoctorPatients(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await patientRepository.syncDoctorPatients('some id');
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      final expectedList = [patient];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      when(() => mockApiService.getDoctorPatients(any())).thenAnswer((_) async => expectedList);
      await patientRepository.syncDoctorPatients(doctor.uuid);
      final savedPatients = await patientRepository.getDoctorPatients(doctor.uuid);
      assert(const ListEquality().equals(savedPatients, expectedList));
    });
  });

  group("getPatientPatients", () {
    test('successful fetch returns patient list', () async {
      final expectedList = [patient];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      when(() => mockApiService.getDoctorPatients(any())).thenAnswer((_) async => expectedList);
      await patientRepository.syncDoctorPatients(doctor.uuid);
      final savedPatients = await patientRepository.getDoctorPatients(doctor.uuid);
      assert(const ListEquality().equals(savedPatients, expectedList));
    });
    test('empty table returns empty list', () async {
      final savedPatients = await patientRepository.getDoctorPatients(doctor.uuid);
      assert(savedPatients.isEmpty);
    });
  });
}
