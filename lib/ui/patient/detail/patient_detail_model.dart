import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/models/session.dart';
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
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PatientDetailModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
    assignmentRepository,
  );
});

class PatientDetailModel extends BaseViewModel<PatientDetailEvent> {
  PatientDetailModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
    this._assignmentRepository,
  ) : super(
          errorEvent: PatientDetailEvent.showSnackbarError,
          messageEvent: PatientDetailEvent.showSnackbarMessage,
          navigateToLoginEvent: PatientDetailEvent.navigateToLoginScreen,
        );

  /* Services */

  final SessionRepository _sessionRepository;
  final AssignmentRepository _assignmentRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;

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

  Future<void> fetchScreenData({required int patientId}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _getUpcomingSessions(patientId: patientId);
    await _getPendingAssignments(patientId: patientId);
    updateUi(() => _isLoading = false);
  }

  Future<void> _getUpcomingSessions({required int patientId}) async {
    final err =
        await _sessionRepository.syncPatientSessions(patientId, upcoming: true);
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _sessions = await _sessionRepository.getPatientSessions(
      patientId,
      upcoming: true,
    );
  }

  Future<void> _getPendingAssignments({required int patientId}) async {
    final err = await _assignmentRepository.syncPatientAssignments(
      patientId,
      pending: true,
    );
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _assignments = await _assignmentRepository.getPatientAssignments(
      patientId,
      pending: true,
    );
  }
}
