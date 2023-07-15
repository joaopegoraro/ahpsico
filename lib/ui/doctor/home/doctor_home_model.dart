import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/invite_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorHomeEvent {
  openInvitePatientBottomSheet,
  openSendAdviceBottomSheet,
  openSendAdviceToAllBottomSheet,
  openLogoutConfirmationDialog,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final doctorHomeModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final inviteRepository = ref.watch(inviteRepositoryProvider);
  final adviceRepository = ref.watch(adviceRepositoryProvider);
  return DoctorHomeModel(
    authService,
    userRepository,
    sessionRepository,
    inviteRepository,
    adviceRepository,
  );
});

class DoctorHomeModel extends ViewModel<DoctorHomeEvent> {
  DoctorHomeModel(
    this._authService,
    this._userRepository,
    this._sessionRepository,
    this._inviteRepository,
    this._adviceRepository,
  );

  /* Services */

  final AuthService _authService;
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;
  final InviteRepository _inviteRepository;
  final AdviceRepository _adviceRepository;

  /* Fields */

  bool _isFetchinScreenData = false;
  bool get isFetchingScreenData => _isFetchinScreenData;

  User? _user;
  User? get user => _user;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isFetchinScreenData = true);
    await _getUserData();
    await _getTodaySessions();
    updateUi(() => _isFetchinScreenData = false);
  }

  Future<void> _getTodaySessions() async {
    try {
      final userUid = _user!.uid;
      final now = DateTime.now();
      await _sessionRepository.syncDoctorSessions(userUid, date: now);
      _sessions = await _sessionRepository.getDoctorSessions(userUid, date: now);
    } catch (_) {}
  }

  Future<void> _getUserData() async {
    try {
      _user = await _userRepository.get();
    } on DatabaseNotFoundException catch (_) {
      // TODO: remove this line
      _user = const User(
        uid: "some uid",
        name: "Andréa Hahmeyer Pegoraro",
        phoneNumber: "49998011606",
        isDoctor: true,
      );
      return;
      // showSnackbar(
      // "Sua sessão expirou!",
      // DoctorHomeEvent.showSnackbarError,
      // );
      // await _userRepository.clear();
      // await _authService.signOut();
      // emitEvent(DoctorHomeEvent.navigateToLoginScreen);
    }
  }
}
