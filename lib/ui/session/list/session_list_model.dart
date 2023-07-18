import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/app/app.dart';
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
  return SessionListModel(
    authService,
    userRepository,
    sessionRepository,
  );
});

class SessionListModel extends BaseViewModel<SessionListEvent> {
  SessionListModel(
    super.authService,
    super.userRepository,
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

  Future<void> fetchScreenData({required String? patientUuid}) async {
    // TODO REMOVE THIS BLOCK
    user = mockUser;
    _sessions = mockSessions;
    return updateUi(() => _isLoading = false);
    // TODO END OF BLOCK

    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchSessions(patientUuid: patientUuid);
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchSessions({String? patientUuid}) async {
    final isDoctor = user!.isDoctor;
    final userUid = user!.uid;
    try {
      if (patientUuid != null) {
        await _sessionRepository.syncPatientSessions(patientUuid);
      } else if (isDoctor) {
        await _sessionRepository.syncDoctorSessions(userUid);
      } else {
        await _sessionRepository.syncPatientSessions(userUid);
      }
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    if (patientUuid != null) {
      _sessions = await _sessionRepository.getPatientSessions(patientUuid);
    } else if (isDoctor) {
      _sessions = await _sessionRepository.getDoctorSessions(userUid);
    } else {
      _sessions = await _sessionRepository.getPatientSessions(userUid);
    }
  }
}
