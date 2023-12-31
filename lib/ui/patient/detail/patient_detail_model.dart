import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:flutter/services.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum PatientDetailEvent {
  openCreateAssignmentSheet,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final patientDetailModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final assignmentRepository = ref.watch(assignmentRepositoryProvider);
  final adviceRepository = ref.watch(adviceRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PatientDetailModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
    assignmentRepository,
    adviceRepository,
  );
});

class PatientDetailModel extends BaseViewModel<PatientDetailEvent> {
  PatientDetailModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
    this._assignmentRepository,
    this._adviceRepository,
  ) : super(
          errorEvent: PatientDetailEvent.showSnackbarError,
          messageEvent: PatientDetailEvent.showSnackbarMessage,
          navigateToLoginEvent: PatientDetailEvent.navigateToLoginScreen,
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

  void addPhoneToClipboard(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber)).then((_) {
      showSnackbar(
        "Telefone copiado para área de transferência",
        PatientDetailEvent.showSnackbarMessage,
      );
    });
  }

  void openCreateAssignmentSheet() {
    emitEvent(PatientDetailEvent.openCreateAssignmentSheet);
  }

  /* Calls */

  Future<void> fetchScreenData({required String patientUuid}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _getUpcomingSessions(patientUuid: patientUuid);
    await _getPendingAssignments(patientUuid: patientUuid);
    await _getReceivedAdvices(patientUuid: patientUuid);
    updateUi(() => _isLoading = false);
  }

  Future<void> _getUpcomingSessions({required String patientUuid}) async {
    final err = await _sessionRepository.syncPatientSessions(patientUuid, upcoming: true);
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _sessions = await _sessionRepository.getPatientSessions(
      patientUuid,
      upcoming: true,
    );
  }

  Future<void> _getPendingAssignments({required String patientUuid}) async {
    final err = await _assignmentRepository.syncPatientAssignments(patientUuid, pending: true);
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _assignments = await _assignmentRepository.getPatientAssignments(
      patientUuid,
      pending: true,
    );
  }

  Future<void> _getReceivedAdvices({required String patientUuid}) async {
    final err = await _adviceRepository.syncPatientAdvices(patientUuid);
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _advices = await _adviceRepository.getPatientAdvices(patientUuid);
  }
}
