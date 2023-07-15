import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorHomeEvent {
  openInvitePatientBottomSheet,
  openSendAdviceBottomSheet,
  openSendAdviceToAllBottomSheet,
  openLogoutDialog,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final doctorHomeModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return DoctorHomeModel(
    authService,
    userRepository,
    sessionRepository,
  );
});

class DoctorHomeModel extends BaseViewModel<DoctorHomeEvent> {
  DoctorHomeModel(
    super.authService,
    super.userRepository,
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

  User? _user;
  User? get user => _user;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  /* Methods */

  void openLogoutDialog() {
    emitEvent(DoctorHomeEvent.openLogoutDialog);
  }

  void openInvitePatientSheet() {
    emitEvent(DoctorHomeEvent.openInvitePatientBottomSheet);
  }

  void openSendAdviceSheet() {
    emitEvent(DoctorHomeEvent.openSendAdviceBottomSheet);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);

    // TODO REMOVE THIS LINE
    _user = const User(
      uid: "some uid",
      name: "Andréa Hahmeyer Pegoraro",
      phoneNumber: "",
      isDoctor: true,
    );
    return updateUi(() => _isLoading = false);

    await _getUserData();
    await _getTodaySessions();
    updateUi(() => _isLoading = false);
  }

  Future<void> _getTodaySessions() async {
    final userUid = _user!.uid;
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

  Future<void> _getUserData() async {
    try {
      await userRepository.sync();
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    try {
      _user = await userRepository.get();
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    }
  }
}
