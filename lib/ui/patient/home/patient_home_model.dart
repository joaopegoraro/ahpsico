import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum PatientHomeEvent {
  openLogoutDialog,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final patientHomeModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final assignmentRepository = ref.watch(assignmentRepositoryProvider);
  final adviceRepository = ref.watch(adviceRepositoryProvider);
  return PatientHomeModel(
    authService,
    userRepository,
    sessionRepository,
    assignmentRepository,
    adviceRepository,
  );
});

class PatientHomeModel extends BaseViewModel<PatientHomeEvent> {
  PatientHomeModel(
    super.authService,
    super.userRepository,
    this._sessionRepository,
    this._assignmentRepository,
    this._adviceRepository,
  ) : super(
          errorEvent: PatientHomeEvent.showSnackbarError,
          messageEvent: PatientHomeEvent.showSnackbarMessage,
          navigateToLoginEvent: PatientHomeEvent.navigateToLoginScreen,
        );

  /* Services */

  final SessionRepository _sessionRepository;
  final AssignmentRepository _assignmentRepository;
  final AdviceRepository _adviceRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;

  List<Advice> _advices = [];
  List<Advice> get advices => _advices;

  /* Methods */

  void openLogoutDialog() {
    emitEvent(PatientHomeEvent.openLogoutDialog);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);

    // TODO REMOVE THIS LINE
    user = const User(
      uid: "some uid",
      name: "Marcos Aurélio",
      phoneNumber: "",
      isDoctor: false,
    );
    _advices = mockAdvices;
    _assignments = mockAssignments;
    _sessions = mockSessions;
    return updateUi(() => _isLoading = false);

    await getUserData(sync: true);
    await _getUpcomingSessions();
    await _getPendingAssignments();
    await _getReceivedAdvices();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getUpcomingSessions() async {
    final userUid = user!.uid;
    try {
      await _sessionRepository.syncPatientSessions(userUid, upcoming: true);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    _sessions = await _sessionRepository.getPatientSessions(
      userUid,
      upcoming: true,
    );
  }

  Future<void> _getPendingAssignments() async {
    final userUid = user!.uid;
    try {
      await _assignmentRepository.syncPatientAssignments(userUid, pending: true);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    _assignments = await _assignmentRepository.getPatientAssignments(
      userUid,
      pending: true,
    );
  }

  Future<void> _getReceivedAdvices() async {
    final userUid = user!.uid;
    try {
      await _adviceRepository.syncPatientAdvices(userUid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    _advices = await _adviceRepository.getPatientAdvices(userUid);
  }
}

const mockDoctor = Doctor(
  uuid: 'some uuid',
  name: "Andréa Hahmeyer Pegoraro",
  phoneNumber: '99999999999',
  description: "Psicólogo de família com mais de 10 anos de experiência",
  crp: "983928392-232",
  pixKey: 'marcos@gmail.com',
  paymentDetails: "Não informado",
);

const mockPatient = Patient(
  uuid: 'oms euid',
  name: "Andréa Pegoraro",
  phoneNumber: '99999999999',
);

final mockAdvices = <Advice>[
  Advice(
    id: 0,
    message: "Não ligue para o que os outros pensam. A única coisa que importa é você!",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
  Advice(
    id: 1,
    message: "Cuide dos outros como gostaria de ser cuidado",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
  Advice(
    id: 3,
    message: "Não espere dos outros o que não esperaria de você mesmo",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
];

final mockAssignments = <Assignment>[
  Assignment(
    id: 0,
    title: "Tarefa da semana",
    description: "Escreva 10 qualidades suas, e 10 defeitos",
    doctor: mockDoctor,
    patientId: mockPatient.uuid,
    status: AssignmentStatus.pending,
    deliverySession: mockSessions.first,
  ),
  Assignment(
    id: 1,
    title: "Tarefa do mês",
    description: "Converse com 3 pessoas no seu trabalho",
    doctor: mockDoctor,
    patientId: mockPatient.uuid,
    status: AssignmentStatus.pending,
    deliverySession: mockSessions.last,
  ),
  Assignment(
    id: 2,
    title: "Para próxima sessão",
    description: "Tente praticar o método de respiração quando sentir vontade de comer demais",
    doctor: mockDoctor,
    patientId: mockPatient.uuid,
    status: AssignmentStatus.pending,
    deliverySession: mockSessions.last,
  ),
];

final mockSessions = <Session>[
  Session(
    id: 0,
    doctor: mockDoctor,
    patient: mockPatient,
    groupId: 0,
    groupIndex: 0,
    status: SessionStatus.confirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 1)),
  ),
  Session(
    id: 1,
    doctor: mockDoctor,
    patient: mockPatient,
    groupId: 0,
    groupIndex: 0,
    status: SessionStatus.notConfirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 7)),
  ),
  Session(
    id: 2,
    doctor: mockDoctor,
    patient: mockPatient,
    groupId: 0,
    groupIndex: 0,
    status: SessionStatus.notConfirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 12)),
  ),
];
