import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum SessionListEvent {
  showSnackbarError,
  navigateToLogin,
}

final sessionListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return SessionListModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
  );
});

class SessionListModel extends BaseViewModel<SessionListEvent> {
  SessionListModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
  ) : super(
          errorEvent: SessionListEvent.showSnackbarError,
          navigateToLoginEvent: SessionListEvent.navigateToLogin,
        );

  /* Services */

  final SessionRepository _sessionRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  /* Calls */

  Future<void> fetchScreenData({
    required int? patientId,
    bool sync = true,
  }) async {
    updateUi(() => _isLoading = sync);
    await getUserData();
    await _fetchSessions(patientId: patientId, sync: sync);
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchSessions({int? patientId, bool sync = true}) async {
    final isDoctor = user!.role.isDoctor;
    final userId = user!.id;

    if (sync) {
      ApiError? err;
      if (patientId != null) {
        err = await _sessionRepository.syncPatientSessions(patientId);
      } else if (isDoctor) {
        err = await _sessionRepository.syncDoctorSessions();
      } else {
        err = await _sessionRepository.syncPatientSessions(userId);
      }
      if (err != null) {
        await handleDefaultErrors(err, shouldShowConnectionError: false);
      }
    }

    if (patientId != null) {
      _sessions = await _sessionRepository.getPatientSessions(patientId);
    } else if (isDoctor) {
      _sessions = await _sessionRepository.getDoctorSessions();
    } else {
      _sessions = await _sessionRepository.getPatientSessions(userId);
    }
  }
}
