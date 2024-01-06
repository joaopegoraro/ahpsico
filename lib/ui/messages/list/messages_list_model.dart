import 'package:ahpsico/data/repositories/message_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/message.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum MessageListEvent {
  openDeleteConfirmationDialog,
  showSnackbarMessage,
  showSnackbarError,
  navigateToLogin,
}

final messageListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final messageRepository = ref.watch(messageRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return MessageListModel(
    authService,
    userRepository,
    preferencesRepository,
    messageRepository,
  );
});

class MessageListModel extends BaseViewModel<MessageListEvent> {
  MessageListModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._messageRepository,
  ) : super(
          errorEvent: MessageListEvent.showSnackbarError,
          messageEvent: MessageListEvent.showSnackbarMessage,
          navigateToLoginEvent: MessageListEvent.navigateToLogin,
        );

  /* Services */

  final MessageRepository _messageRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  final List<int> _selectedMessagesIds = [];
  List<int> get selectedMessagesIds => _selectedMessagesIds;

  bool get areAllMessagesSelected =>
      selectedMessagesIds.length == messages.length;

  bool get isSelectModeOn => selectedMessagesIds.isNotEmpty;

  /* Methods */

  void openDeleteConfirmationDialog() {
    emitEvent(MessageListEvent.openDeleteConfirmationDialog);
  }

  void selectMessage(Message message) {
    updateUi(() {
      if (!_selectedMessagesIds.remove(message.id)) {
        _selectedMessagesIds.add(message.id);
      }
    });
  }

  void clearSelection() {
    updateUi(() {
      _selectedMessagesIds.clear();
    });
  }

  /* Calls */

  Future<void> fetchScreenData({required int? patientId}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchMessages(patientId: patientId);
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchMessages({required int? patientId}) async {
    ApiError? err;
    if (patientId != null) {
      err = await _messageRepository.syncPatientMessages(patientId);
    } else {
      err = await _messageRepository.syncDoctorMessages();
    }
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _messages = await _messageRepository.getMessages();
  }

  Future<void> deleteSelectedMessages() async {
    updateUi(() => _isLoading = true);

    for (final messageId in _selectedMessagesIds) {
      final err = await _messageRepository.delete(messageId);
      if (err != null) {
        clearSelection();
        updateUi(() => _isLoading = false);
        return await handleDefaultErrors(err);
      }
    }

    _messages
        .removeWhere((message) => _selectedMessagesIds.contains(message.id));
    clearSelection();
    showSnackbar(
      "Mensagens deletadas com sucesso!",
      MessageListEvent.showSnackbarMessage,
    );
    updateUi(() => _isLoading = false);
  }
}
