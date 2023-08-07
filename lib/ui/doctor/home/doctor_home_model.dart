import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorHomeEvent {
  openInvitePatientBottomSheet,
  openLogoutDialog,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final doctorHomeModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return DoctorHomeModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
  );
});

class DoctorHomeModel extends BaseViewModel<DoctorHomeEvent> {
  DoctorHomeModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
  ) : super(
          errorEvent: DoctorHomeEvent.showSnackbarError,
          messageEvent: DoctorHomeEvent.showSnackbarMessage,
          navigateToLoginEvent: DoctorHomeEvent.navigateToLoginScreen,
        );

  /* Services */
  final SessionRepository _sessionRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  /* Methods */

  void openLogoutDialog() {
    emitEvent(DoctorHomeEvent.openLogoutDialog);
  }

  void openInvitePatientSheet() {
    emitEvent(DoctorHomeEvent.openInvitePatientBottomSheet);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData(sync: true);
    await _getTodaySessions();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getTodaySessions() async {
    final userUid = user!.uuid;
    final now = DateTime.now();
    try {
      await _sessionRepository.syncDoctorSessions(userUid, date: now);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    _sessions = await _sessionRepository.getDoctorSessions(userUid, date: now);
  }
}
