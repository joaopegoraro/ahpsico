import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/doctor_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum SendMessageEvent {
  openConfirmationDialog,
  closeSheet,
  showSnackbarError,
  showSnackbarMessage,
  navigateToLoginScreen,
}

final sendMessageModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final adviceRepository = ref.watch(adviceRepositoryProvider);
  final doctorRepository = ref.watch(doctorRepositoryProvider);
  return SendMessageModel(
    adviceRepository,
    doctorRepository,
    authService,
    userRepository,
  );
});

class SendMessageModel extends BaseViewModel<SendMessageEvent> {
  SendMessageModel(
    this._adviceRepository,
    this._doctorRepository,
    super.authService,
    super.userRepository,
  ) : super(
          errorEvent: SendMessageEvent.showSnackbarError,
          navigateToLoginEvent: SendMessageEvent.navigateToLoginScreen,
        );

  /* Services */

  final AdviceRepository _adviceRepository;
  final DoctorRepository _doctorRepository;

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

    try {
      await getUserData();
      final doctor = await _doctorRepository.get(user!.uid);
      final advice = Advice(
        id: 0,
        message: message,
        doctor: doctor,
        patientIds: patientIds,
      );
      await _adviceRepository.create(advice);
      showSnackbar(
        "Mensagem enviada com sucesso!",
        SendMessageEvent.showSnackbarMessage,
      );
      emitEvent(SendMessageEvent.closeSheet);
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    updateUi(() => _isLoading = false);
  }
}
