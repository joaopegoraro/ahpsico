import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/data/database/entities/doctor_entity.dart';
import 'package:ahpsico/data/database/entities/patient_entity.dart';
import 'package:ahpsico/data/database/entities/assignment_entity.dart';
import 'package:ahpsico/data/database/entities/session_entity.dart';
import 'package:ahpsico/data/database/mappers/doctor_mapper.dart';
import 'package:ahpsico/data/database/mappers/patient_mapper.dart';
import 'package:ahpsico/data/database/mappers/assignment_mapper.dart';
import 'package:ahpsico/data/database/mappers/session_mapper.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

class MockApiService extends Mock implements ApiService {}

class MockAssignment extends Mock implements Assignment {}

void main() {
  final faker = Faker();

  late final sqflite.Database database;
  final mockApiService = MockApiService();
  late final AssignmentRepository assignmentRepository;
  final mockAssignment = MockAssignment();

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

  final DateFormat formatter = DateFormat("yyyy-MM-ddThh:mm:ssZ");
  final session = Session(
    id: 0,
    doctor: doctor,
    patient: patient,
    groupId: faker.hashCode,
    groupIndex: 0,
    status: SessionStatus.canceled,
    type: SessionType.monthly,
    date: formatter.format(faker.date.dateTime()),
  );

  final assignment = Assignment(
    id: 0,
    doctor: doctor,
    patientId: patient.uuid,
    title: faker.lorem.sentence(),
    description: faker.lorem.sentence(),
    status: AssignmentStatus.done,
    deliverySession: session,
  );

  setUpAll(() async {
    registerFallbackValue(assignment);

    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi..deleteDatabase(AhpsicoDatabase.dbName);
    database = await AhpsicoDatabase.instance;
    assignmentRepository = AssignmentRepositoryImpl(
      apiService: mockApiService,
      database: database,
    );
  });

  tearDownAll(() async {
    await database.close();
    sqflite_ffi.databaseFactory.deleteDatabase(AhpsicoDatabase.dbName);
  });

  tearDown(() async {
    await assignmentRepository.clear();
    await database.delete(DoctorEntity.tableName);
    await database.delete(PatientEntity.tableName);
    await database.delete(SessionEntity.tableName);
  });

  group("create", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.createAssignment(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await assignmentRepository.create(mockAssignment);
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('db error throws', () async {
      when(() => mockApiService.createAssignment(any())).thenAnswer((_) async => mockAssignment);
      when(() => mockAssignment.id).thenThrow(const DatabaseInsertException());
      try {
        await assignmentRepository.create(mockAssignment);
        assert(false);
      } on DatabaseInsertException catch (_) {
        assert(true);
      }
    });

    test('successful updates saves to db and returns updated assignment', () async {
      when(() => mockApiService.createAssignment(any())).thenAnswer((_) async => assignment);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(SessionEntity.tableName, SessionMapper.toEntity(session).toMap());
      final updatedAssignment = await assignmentRepository.create(assignment);
      final savedAssignmentMap = await database.query(
        AssignmentEntity.tableName,
        where: "${AssignmentEntity.idColumn} = ?",
        whereArgs: [assignment.id],
      );
      final savedAssignment = AssignmentMapper.toAssignment(
        AssignmentEntity.fromMap(savedAssignmentMap.first),
        sessionEntity: SessionMapper.toEntity(session),
        doctorEntity: DoctorMapper.toEntity(doctor),
        patientEntity: PatientMapper.toEntity(patient),
      );
      assert(savedAssignment == assignment);
      assert(updatedAssignment == assignment);
    });
  });

  group("update", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.updateAssignment(any())).thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await assignmentRepository.update(mockAssignment);
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('db error throws', () async {
      when(() => mockApiService.updateAssignment(any())).thenAnswer((_) async => mockAssignment);
      when(() => mockAssignment.id).thenThrow(const DatabaseInsertException());
      try {
        await assignmentRepository.update(mockAssignment);
        assert(false);
      } on DatabaseInsertException catch (_) {
        assert(true);
      }
    });

    test('successful updates saves to db and returns updated assignment', () async {
      when(() => mockApiService.updateAssignment(any())).thenAnswer((_) async => assignment);
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(SessionEntity.tableName, SessionMapper.toEntity(session).toMap());
      final updatedAssignment = await assignmentRepository.update(assignment);
      final savedAssignmentMap = await database.query(
        AssignmentEntity.tableName,
        where: "${AssignmentEntity.idColumn} = ?",
        whereArgs: [assignment.id],
      );
      final savedAssignment = AssignmentMapper.toAssignment(
        AssignmentEntity.fromMap(savedAssignmentMap.first),
        sessionEntity: SessionMapper.toEntity(session),
        doctorEntity: DoctorMapper.toEntity(doctor),
        patientEntity: PatientMapper.toEntity(patient),
      );
      assert(savedAssignment == assignment);
      assert(updatedAssignment == assignment);
    });
  });

  group("syncPatientAssignments", () {
    test('api error throws', () async {
      const code = "some code";
      when(() => mockApiService.getPatientAssignments(any()))
          .thenAnswer((_) async => throw const ApiException(code: code));
      try {
        await assignmentRepository.syncPatientAssignments('some id');
        assert(false);
      } on ApiException catch (e) {
        assert(e.code == code);
      }
    });

    test('db error throws', () async {
      when(() => mockApiService.getPatientAssignments(any())).thenAnswer((_) async => [mockAssignment]);
      when(() => mockAssignment.id).thenThrow(const DatabaseInsertException());
      try {
        await assignmentRepository.syncPatientAssignments('some id');
        assert(false);
      } on DatabaseInsertException catch (_) {
        assert(true);
      }
    });

    test('successful sync saves to db', () async {
      final expectedList = [assignment];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(SessionEntity.tableName, SessionMapper.toEntity(session).toMap());
      when(() => mockApiService.getPatientAssignments(any())).thenAnswer((_) async => expectedList);
      await assignmentRepository.syncPatientAssignments(patient.uuid);
      final savedAssignments = await assignmentRepository.getPatientAssignments(patient.uuid);
      assert(const ListEquality().equals(savedAssignments, expectedList));
    });
  });

  group("getPatientAssignments", () {
    test('successful fetch returns assignment list', () async {
      final expectedList = [assignment];
      await database.insert(DoctorEntity.tableName, DoctorMapper.toEntity(doctor).toMap());
      await database.insert(PatientEntity.tableName, PatientMapper.toEntity(patient).toMap());
      await database.insert(SessionEntity.tableName, SessionMapper.toEntity(session).toMap());
      when(() => mockApiService.getPatientAssignments(any())).thenAnswer((_) async => expectedList);
      await assignmentRepository.syncPatientAssignments(patient.uuid);
      final savedAssignments = await assignmentRepository.getPatientAssignments(patient.uuid);
      assert(const ListEquality().equals(savedAssignments, expectedList));
    });
  });
}
