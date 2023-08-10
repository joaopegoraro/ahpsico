import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/doctor_repository.dart';
import 'package:ahpsico/data/repositories/invite_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/session/session.dart';
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
  final doctorRepository = ref.watch(doctorRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PatientHomeModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
    assignmentRepository,
    adviceRepository,
    inviteRepository,
    doctorRepository,
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
    this._doctorRepository,
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
  final DoctorRepository _doctorRepository;

  /* Fields */

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

  Future<void> fetchScreenData({bool sync = true}) async {
    updateUi(() => _isLoading = sync);

    await getUserData(sync: sync);

    if (sync) {
      await _syncPatientDoctors();
    }

    await _getUpcomingSessions(sync: sync);
    await _getPendingAssignments(sync: sync);
    await _getReceivedAdvices(sync: sync);
    await _getReceivedInvites(sync: sync);

    updateUi(() => _isLoading = false);
  }

  Future<void> _syncPatientDoctors() async {
    final err = await _doctorRepository.syncPatientDoctors(user!.uuid);
    if (err != null) {
      return await handleDefaultErrors(err, shouldShowConnectionError: false);
    }
  }

  Future<void> _getUpcomingSessions({bool sync = true}) async {
    final userUid = user!.uuid;

    if (sync) {
      final err = await _sessionRepository.syncPatientSessions(userUid, upcoming: true);
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
    final userUid = user!.uuid;

    if (sync) {
      final err = await _assignmentRepository.syncPatientAssignments(userUid, pending: true);
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    _assignments = await _assignmentRepository.getPatientAssignments(
      userUid,
      pending: true,
    );
  }

  Future<void> _getReceivedAdvices({bool sync = true}) async {
    final userUid = user!.uuid;

    if (sync) {
      final err = await _adviceRepository.syncPatientAdvices(userUid);
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    _advices = await _adviceRepository.getPatientAdvices(userUid);
  }

  Future<void> _getReceivedInvites({bool sync = true}) async {
    if (sync) {
      final err = await _inviteRepository.sync();
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    _invites = await _inviteRepository.get();
  }

  Future<void> acceptInvite(Invite invite) async {
    updateUi(() => _isLoading = true);
    final err = await _inviteRepository.accept(invite.id);
    if (err != null) {
      updateUi(() => _isLoading = false);
      return await handleDefaultErrors(err);
    }
    await fetchScreenData();
    updateUi(() => _isLoading = false);
  }

  Future<void> denyInvite(Invite invite) async {
    updateUi(() => _isLoading = true);
    final err = await _inviteRepository.delete(invite.id);
    if (err != null) {
      updateUi(() => _isLoading = false);
      return await handleDefaultErrors(err);
    }
    await fetchScreenData();
    updateUi(() => _isLoading = false);
  }
}
