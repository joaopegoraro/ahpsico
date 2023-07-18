import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/patient_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum PatientHomeEvent {
  openLogoutDialog,
  openEditNameSheet,
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
  final patientRepository = ref.watch(patientRepositoryProvider);
  return PatientHomeModel(
    authService,
    userRepository,
    patientRepository,
    sessionRepository,
    assignmentRepository,
    adviceRepository,
  );
});

class PatientHomeModel extends BaseViewModel<PatientHomeEvent> {
  PatientHomeModel(
    super.authService,
    super.userRepository,
    this._patientRepository,
    this._sessionRepository,
    this._assignmentRepository,
    this._adviceRepository,
  ) : super(
          errorEvent: PatientHomeEvent.showSnackbarError,
          messageEvent: PatientHomeEvent.showSnackbarMessage,
          navigateToLoginEvent: PatientHomeEvent.navigateToLoginScreen,
        );

  /* Services */

  final PatientRepository _patientRepository;
  final SessionRepository _sessionRepository;
  final AssignmentRepository _assignmentRepository;
  final AdviceRepository _adviceRepository;

  /* Fields */

  Patient? _patient;
  Patient? get patient => _patient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;

  List<Advice> _advices = [];
  List<Advice> get advices => _advices;

  /* Methods */

  void openEditNameSheet() {
    emitEvent(PatientHomeEvent.openEditNameSheet);
  }

  void openLogoutDialog() {
    emitEvent(PatientHomeEvent.openLogoutDialog);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData(sync: true);
    await _getPatientData();
    await _getUpcomingSessions();
    await _getPendingAssignments();
    await _getReceivedAdvices();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getPatientData() async {
    try {
      await _patientRepository.sync(user!.uid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    try {
      _patient = await _patientRepository.get(user!.uid);
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    }
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
