import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/invite_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum PatientHomeEvent {
  openLogoutDialog,
  openAcceptInviteDialog,
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
  final inviteRepository = ref.watch(inviteRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PatientHomeModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
    assignmentRepository,
    adviceRepository,
    inviteRepository,
  );
});

class PatientHomeModel extends BaseViewModel<PatientHomeEvent> {
  PatientHomeModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
    this._assignmentRepository,
    this._adviceRepository,
    this._inviteRepository,
  ) : super(
          errorEvent: PatientHomeEvent.showSnackbarError,
          messageEvent: PatientHomeEvent.showSnackbarMessage,
          navigateToLoginEvent: PatientHomeEvent.navigateToLoginScreen,
        );

  /* Services */

  final SessionRepository _sessionRepository;
  final AssignmentRepository _assignmentRepository;
  final AdviceRepository _adviceRepository;
  final InviteRepository _inviteRepository;

  /* Fields */

  User? _patient;
  User? get patient => _patient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;

  List<Advice> _advices = [];
  List<Advice> get advices => _advices;

  List<Invite> _invites = [];
  List<Invite> get invites => _invites;

  Invite? _selectedInvite;
  Invite? get selectedInvite => _selectedInvite;

  /* Methods */

  void openEditNameSheet() {
    emitEvent(PatientHomeEvent.openEditNameSheet);
  }

  void openLogoutDialog() {
    emitEvent(PatientHomeEvent.openLogoutDialog);
  }

  void openAcceptInviteDialog(Invite invite) {
    _selectedInvite = invite;
    emitEvent(PatientHomeEvent.openAcceptInviteDialog);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData(sync: true);
    await _getUpcomingSessions();
    await _getPendingAssignments();
    await _getReceivedAdvices();
    await _getReceivedInvites();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getUpcomingSessions() async {
    final userUid = user!.uuid;
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
    final userUid = user!.uuid;
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
    final userUid = user!.uuid;
    try {
      await _adviceRepository.syncPatientAdvices(userUid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    _advices = await _adviceRepository.getPatientAdvices(userUid);
  }

  Future<void> _getReceivedInvites() async {
    try {
      await _inviteRepository.sync();
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    } on ApiInvitesNotFoundException catch (_) {
      _invites = [];
      return;
    }
    _invites = await _inviteRepository.get();
  }

  Future<void> acceptInvite(Invite invite) async {
    updateUi(() => _isLoading = true);
    try {
      await _inviteRepository.accept(invite.id);
      fetchScreenData();
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    updateUi(() => _isLoading = false);
  }

  Future<void> denyInvite(Invite invite) async {
    updateUi(() => _isLoading = true);
    try {
      await _inviteRepository.delete(invite.id);
      fetchScreenData();
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    updateUi(() => _isLoading = false);
  }
}
