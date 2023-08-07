import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum SessionDetailEvent {
  concludeSession,
  cancelSession,
  confirmSession,
  showSnackbarError,
  showSnackbarMessage,
  navigateToLogin,
}

final sessionDetailModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return SessionDetailModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
  );
});

class SessionDetailModel extends BaseViewModel<SessionDetailEvent> {
  SessionDetailModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
  ) : super(
          errorEvent: SessionDetailEvent.showSnackbarError,
          messageEvent: SessionDetailEvent.showSnackbarMessage,
          navigateToLoginEvent: SessionDetailEvent.navigateToLogin,
        );

  /* Services */

  final SessionRepository _sessionRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Method */

  void emitCancelSessionEvent() {
    emitEvent(SessionDetailEvent.cancelSession);
  }

  void emitConcludeSessionEvent() {
    emitEvent(SessionDetailEvent.concludeSession);
  }

  void emitConfirmSessionEvent() {
    emitEvent(SessionDetailEvent.confirmSession);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    updateUi(() => _isLoading = false);
  }

  Future<Session?> confirmSession(Session session) async {
    updateUi(() => _isLoading = true);
    Session? newSession;
    try {
      newSession = await _sessionRepository.update(
        session.copyWith(status: SessionStatus.confirmed),
      );
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    updateUi(() => _isLoading = false);
    showSnackbar(
      "Sessão confirmada com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
    return newSession;
  }

  Future<Session?> cancelSession(Session session) async {
    updateUi(() => _isLoading = true);
    Session? newSession;
    try {
      newSession = await _sessionRepository.update(
        session.copyWith(status: SessionStatus.canceled),
      );
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    updateUi(() => _isLoading = false);
    showSnackbar(
      "Sessão cancelada com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
    return newSession;
  }

  Future<Session?> concludeSession(Session session) async {
    updateUi(() => _isLoading = true);
    Session? newSession;
    try {
      newSession = await _sessionRepository.update(
        session.copyWith(status: SessionStatus.concluded),
      );
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    updateUi(() => _isLoading = false);
    showSnackbar(
      "Sessão concluída com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
    return newSession;
  }
}
