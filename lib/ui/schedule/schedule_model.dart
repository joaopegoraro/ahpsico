import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum ScheduleEvent {
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final scheduleModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return ScheduleModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
  );
});

class ScheduleModel extends BaseViewModel<ScheduleEvent> {
  ScheduleModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
  ) : super(
          errorEvent: ScheduleEvent.showSnackbarError,
          messageEvent: ScheduleEvent.showSnackbarMessage,
          navigateToLoginEvent: ScheduleEvent.navigateToLoginScreen,
        );

  /* Services */
  final SessionRepository _sessionRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  /* Methods */

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _getSessions();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getSessions() async {
    final userUid = user!.uuid;
    final isDoctor = user!.role.isDoctor;
    try {
      if (isDoctor) {
        await _sessionRepository.syncDoctorSessions(userUid);
      } else {
        await _sessionRepository.syncPatientSessions(userUid);
      }
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    if (isDoctor) {
      _sessions = await _sessionRepository.getDoctorSessions(userUid);
    } else {
      _sessions = await _sessionRepository.getPatientSessions(userUid);
    }
  }
}
