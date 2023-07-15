import 'dart:math';

import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/invite_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
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

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await _getUserData();
    await _getTodaySessions();
    updateUi(() => _isLoading = false);
  }

  Future<void> logout({required bool showMessage}) async {
    await _userRepository.clear();
    await _authService.signOut();
    if (showMessage) {
      showSnackbar(
        "Logout bem sucedido!",
        DoctorHomeEvent.showSnackbarMessage,
      );
    }
    emitEvent(DoctorHomeEvent.navigateToLoginScreen);
  }

  Future<void> _getTodaySessions() async {
    try {
      final userUid = _user!.uid;
      final now = DateTime.now();
      await _sessionRepository.syncDoctorSessions(userUid, date: now);
      _sessions = await _sessionRepository.getDoctorSessions(userUid, date: now);
    } on ApiConnectionException catch (_) {
      showSnackbar(
        "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet",
        DoctorHomeEvent.showSnackbarError,
      );
    }
  }

  Future<void> _getUserData() async {
    try {
      _user = await _userRepository.get();
    } on DatabaseNotFoundException catch (_) {
      showSnackbar(
        "Sua sessão expirou!",
        DoctorHomeEvent.showSnackbarError,
      );
      await logout(showMessage: false);
    }
  }
}
