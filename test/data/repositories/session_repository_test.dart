import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/user_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

class MockApiService extends Mock implements ApiService {}

class MockSession extends Mock implements Session {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final SessionRepository sessionRepository;
  final mockSession = MockSession();

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

  final session = Session(
    id: 0,
    doctor: doctor,
    patient: patient,
    groupId: faker.hashCode,
    groupIndex: 0,
    status: SessionStatus.canceled,
    type: SessionType.monthly,
    date: DateTime.fromMillisecondsSinceEpoch(faker.date.dateTime().millisecondsSinceEpoch),
  );

  setUpAll(() async {
    registerFallbackValue(session);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi
      ..deleteDatabase(AhpsicoDatabase.dbName);
    database = await AhpsicoDatabase.instance;
    sessionRepository = SessionRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await sessionRepository.clear();
    await database.delete(DoctorEntity.tableName);
    await database.delete(PatientEntity.tableName);
  });

  group("create", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.createSession(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await sessionRepository.create(mockSession);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful updates saves to db and returns updated session', () async {
      when(() => mockApiService.createSession(any())).thenAnswer((_) async => session);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      final updatedSession = await sessionRepository.create(session);
      final savedSessionMap = await database.query(
        SessionEntity.tableName,
        where: "${SessionEntity.idColumn} = ?",
        whereArgs: [session.id],
      );
      final savedSession = SessionMapper.toSession(
        SessionEntity.fromMap(savedSessionMap.first),
        doctorEntity: DoctorMapper.toEntity(doctor),
        patientEntity: PatientMapper.toEntity(patient),
      );
      assert(savedSession == session);
      assert(updatedSession == session);
    });
  });

  group("update", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.updateSession(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await sessionRepository.update(mockSession);
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful updates saves to db and returns updated session', () async {
      when(() => mockApiService.updateSession(any())).thenAnswer((_) async => session);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      final updatedSession = await sessionRepository.update(session);
      final savedSessionMap = await database.query(
        SessionEntity.tableName,
        where: "${SessionEntity.idColumn} = ?",
        whereArgs: [session.id],
      );
      final savedSession = SessionMapper.toSession(
        SessionEntity.fromMap(savedSessionMap.first),
        doctorEntity: DoctorMapper.toEntity(doctor),
        patientEntity: PatientMapper.toEntity(patient),
      );
      assert(savedSession == session);
      assert(updatedSession == session);
    });
  });

  group("syncDoctorSessions", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getDoctorSessions(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await sessionRepository.syncDoctorSessions('some id');
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      final expectedList = [session];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getDoctorSessions(any())).thenAnswer((_) async => expectedList);
      await sessionRepository.syncDoctorSessions(doctor.uuid);
      final savedSessions = await sessionRepository.getDoctorSessions(doctor.uuid);
      assert(const ListEquality().equals(savedSessions, expectedList));
    });
  });

  group("getDoctorSessions", () {
    test('successful fetch returns session list', () async {
      final expectedList = [session];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getDoctorSessions(any())).thenAnswer((_) async => expectedList);
      await sessionRepository.syncDoctorSessions(doctor.uuid);
      final savedSessions = await sessionRepository.getDoctorSessions(doctor.uuid);
      assert(const ListEquality().equals(savedSessions, expectedList));
    });
    test('empty table returns empty list', () async {
      final savedSessions = await sessionRepository.getDoctorSessions(doctor.uuid);
      assert(savedSessions.isEmpty);
    });
  });

  group("syncPatientSessions", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getPatientSessions(any()))
          .thenAnswer((_) async => throw const ApiError(code: code));
      try {
        await sessionRepository.syncPatientSessions('some id');
        assert(false);
      } on ApiError catch (e) {
        assert(e.code == code);
      }
    });

    test('successful sync saves to db', () async {
      final expectedList = [session];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getPatientSessions(any())).thenAnswer((_) async => expectedList);
      await sessionRepository.syncPatientSessions(patient.uuid);
      final savedSessions = await sessionRepository.getPatientSessions(patient.uuid);
      assert(const ListEquality().equals(savedSessions, expectedList));
    });
  });

  group("getPatientSessions", () {
    test('successful fetch returns session list', () async {
      final expectedList = [session];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      when(() => mockApiService.getPatientSessions(any())).thenAnswer((_) async => expectedList);
      await sessionRepository.syncPatientSessions(patient.uuid);
      final savedSessions = await sessionRepository.getPatientSessions(patient.uuid);
      assert(const ListEquality().equals(savedSessions, expectedList));
    });
    test('empty table returns empty list', () async {
      final savedSessions = await sessionRepository.getPatientSessions(patient.uuid);
      assert(savedSessions.isEmpty);
    });
  });
}
