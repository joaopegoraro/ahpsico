import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/app/app.dart';
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
  return ScheduleModel(
    authService,
    userRepository,
    sessionRepository,
  );
});

class ScheduleModel extends BaseViewModel<ScheduleEvent> {
  ScheduleModel(
    super.authService,
    super.userRepository,
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
    // TODO REMOVE BLOCK
    user = mockUser.copyWith(isDoctor: false);
    _sessions = mockSessions;
    return updateUi(() => _isLoading = false);
    // TODO END OF BLOCK

    updateUi(() => _isLoading = true);
    await getUserData(sync: true);
    await _getTodaySessions();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getTodaySessions() async {
    final userUid = user!.uid;
    final isDoctor = user!.isDoctor;
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
