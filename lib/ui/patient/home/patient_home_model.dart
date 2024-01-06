import 'package:ahpsico/data/repositories/message_repository.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/message.dart';
import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/models/session.dart';
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
  final messageRepository = ref.watch(messageRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PatientHomeModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
    assignmentRepository,
    messageRepository,
  );
});

class PatientHomeModel extends BaseViewModel<PatientHomeEvent> {
  PatientHomeModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
    this._assignmentRepository,
    this._messageRepository,
  ) : super(
          errorEvent: PatientHomeEvent.showSnackbarError,
          messageEvent: PatientHomeEvent.showSnackbarMessage,
          navigateToLoginEvent: PatientHomeEvent.navigateToLoginScreen,
        );

  /* Services */

  final SessionRepository _sessionRepository;
  final AssignmentRepository _assignmentRepository;
  final MessageRepository _messageRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  /* Methods */

  void openEditNameSheet() {
    emitEvent(PatientHomeEvent.openEditNameSheet);
  }

  void openLogoutDialog() {
    emitEvent(PatientHomeEvent.openLogoutDialog);
  }

  /* Calls */

  Future<void> fetchScreenData({bool sync = true}) async {
    updateUi(() => _isLoading = sync);

    await getUserData(sync: sync);

    await _getUpcomingSessions(sync: sync);
    await _getPendingAssignments(sync: sync);
    await _getReceivedMessages(sync: sync);

    updateUi(() => _isLoading = false);
  }

  Future<void> _getUpcomingSessions({bool sync = true}) async {
    final userUid = user!.id;

    if (sync) {
      final err =
          await _sessionRepository.syncPatientSessions(userUid, upcoming: true);
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    _sessions = await _sessionRepository.getPatientSessions(
      userUid,
      upcoming: true,
    );
  }

  Future<void> _getPendingAssignments({bool sync = true}) async {
    final userUid = user!.id;

    if (sync) {
      final err = await _assignmentRepository.syncPatientAssignments(userUid,
          pending: true);
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    _assignments = await _assignmentRepository.getPatientAssignments(
      userUid,
      pending: true,
    );
  }

  Future<void> _getReceivedMessages({bool sync = true}) async {
    final userUid = user!.id;

    if (sync) {
      final err = await _messageRepository.syncPatientMessages(userUid);
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    _messages = await _messageRepository.getMessages();
  }
}
