import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/constants/session_payment_status.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum SessionDetailEvent {
  concludeSession,
  cancelSession,
  confirmSession,
  paySession,
  rescheduleSession,
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

  Session? _updatedSession;
  Session? get updatedSession => _updatedSession;

  /* Method */

  void setUpdatedSession(Session? updatedSession) {
    _updatedSession = updatedSession;
  }

  void emitCancelSessionEvent() {
    emitEvent(SessionDetailEvent.cancelSession);
  }

  void emitConcludeSessionEvent() {
    emitEvent(SessionDetailEvent.concludeSession);
  }

  void emitConfirmSessionEvent() {
    emitEvent(SessionDetailEvent.confirmSession);
  }

  void emitPaySessionEvent() {
    emitEvent(SessionDetailEvent.paySession);
  }

  void emitRescheduleSessionEvent() {
    emitEvent(SessionDetailEvent.rescheduleSession);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    updateUi(() => _isLoading = false);
  }

  Future<void> confirmSession(Session session) async {
    updateUi(() => _isLoading = true);

    final (newSession, err) = await _sessionRepository.update(
      session.copyWith(status: SessionStatus.confirmed),
    );
    if (err != null) {
      await handleDefaultErrors(err);
      return updateUi(() => _isLoading = false);
    }

    updateUi(() {
      _isLoading = false;
      setUpdatedSession(newSession);
    });
    showSnackbar(
      "Sessão confirmada com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
  }

  Future<void> cancelSession(Session session) async {
    updateUi(() => _isLoading = true);
    final (newSession, err) = await _sessionRepository.update(
      session.copyWith(status: SessionStatus.canceled),
    );
    if (err != null) {
      await handleDefaultErrors(err);
      return updateUi(() => _isLoading = false);
    }

    updateUi(() {
      _isLoading = false;
      setUpdatedSession(newSession);
    });
    showSnackbar(
      "Sessão cancelada com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
  }

  Future<void> concludeSession(Session session) async {
    updateUi(() => _isLoading = true);
    final (newSession, err) = await _sessionRepository.update(
      session.copyWith(status: SessionStatus.concluded),
    );
    if (err != null) {
      await handleDefaultErrors(err);
      updateUi(() => _isLoading = false);
      return;
    }
    updateUi(() {
      _isLoading = false;
      setUpdatedSession(newSession);
    });
    showSnackbar(
      "Sessão concluída com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
  }

  Future<void> paySession(Session session) async {
    updateUi(() => _isLoading = true);
    final (newSession, err) = await _sessionRepository.update(
      session.copyWith(paymentStatus: SessionPaymentStatus.payed),
    );
    if (err != null) {
      await handleDefaultErrors(err);
      updateUi(() => _isLoading = false);
      return;
    }
    updateUi(() {
      _isLoading = false;
      setUpdatedSession(newSession);
    });
    showSnackbar(
      "Sessão marcada como paga com sucesso!",
      SessionDetailEvent.showSnackbarMessage,
    );
  }
}
