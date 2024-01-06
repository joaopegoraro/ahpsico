import 'package:ahpsico/data/repositories/message_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/message.dart';
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
  final messageRepository = ref.watch(messageRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return SendMessageModel(
    authService,
    userRepository,
    preferencesRepository,
    messageRepository,
  );
});

class SendMessageModel extends BaseViewModel<SendMessageEvent> {
  SendMessageModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._messageRepository,
  ) : super(
          errorEvent: SendMessageEvent.showSnackbarError,
          navigateToLoginEvent: SendMessageEvent.navigateToLoginScreen,
        );

  /* Services */

  final MessageRepository _messageRepository;

  /* Fields */

  String _text = "";
  String get text => _text;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void updateMessage(String text) {
    _text = text;
  }

  void openConfirmationDialog() {
    if (text.isEmpty) {
      return showSnackbar(
        "O campo de mensagem não pode ficar vazio",
        SendMessageEvent.showSnackbarError,
      );
    }

    emitEvent(SendMessageEvent.openConfirmationDialog);
  }

  /* Calls */

  Future<void> sendMessage(List<int> patientIds) async {
    updateUi(() => _isLoading = true);

    await getUserData();
    final message = Message(
      id: 0,
      text: text,
      createdAt: DateTime.now(),
    );
    final (_, err) = await _messageRepository.create(
      message,
      userIds: patientIds,
    );
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
