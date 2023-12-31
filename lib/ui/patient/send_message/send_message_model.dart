import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum SendMessageEvent {
  openConfirmationDialog,
  closeSheet,
  showSnackbarError,
  showSnackbarMessage,
  navigateToHomeScreen,
  navigateToLoginScreen,
}

final sendMessageModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final adviceRepository = ref.watch(adviceRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return SendMessageModel(
    authService,
    userRepository,
    preferencesRepository,
    adviceRepository,
  );
});

class SendMessageModel extends BaseViewModel<SendMessageEvent> {
  SendMessageModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._adviceRepository,
  ) : super(
          errorEvent: SendMessageEvent.showSnackbarError,
          navigateToLoginEvent: SendMessageEvent.navigateToLoginScreen,
        );

  /* Services */

  final AdviceRepository _adviceRepository;

  /* Fields */

  String _message = "";
  String get message => _message;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void updateMessage(String message) {
    _message = message;
  }

  void openConfirmationDialog() {
    if (message.isEmpty) {
      return showSnackbar(
        "O campo de mensagem não pode ficar vazio",
        SendMessageEvent.showSnackbarError,
      );
    }

    emitEvent(SendMessageEvent.openConfirmationDialog);
  }

  /* Calls */

  Future<void> sendMessage(List<String> patientIds) async {
    updateUi(() => _isLoading = true);

    await getUserData();
    final advice = Advice(
      id: 0,
      message: message,
      doctor: user!,
      patientIds: patientIds,
    );
    final (_, err) = await _adviceRepository.create(advice);
    if (err != null) {
      await handleDefaultErrors(err);
      return updateUi(() => _isLoading = false);
    }
    showSnackbar(
      "Mensagem enviada com sucesso!",
      SendMessageEvent.showSnackbarMessage,
    );
    emitEvent(SendMessageEvent.closeSheet);
    emitEvent(SendMessageEvent.navigateToHomeScreen);

    updateUi(() => _isLoading = false);
  }
}
