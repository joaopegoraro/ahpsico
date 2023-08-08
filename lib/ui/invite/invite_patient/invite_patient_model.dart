import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/data/repositories/invite_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum InvitePatientEvent {
  openPatientNotRegisteredDialog,
  showSnackbarError,
  showSnackbarMessage,
  closeSheet,
  navigateToLoginScreen,
}

final invitePatientModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final inviteRepository = ref.watch(inviteRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return InvitePatientModel(
    authService,
    userRepository,
    preferencesRepository,
    inviteRepository,
  );
});

class InvitePatientModel extends BaseViewModel<InvitePatientEvent> {
  InvitePatientModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._inviteRepository,
  ) : super(
          errorEvent: InvitePatientEvent.showSnackbarError,
          navigateToLoginEvent: InvitePatientEvent.navigateToLoginScreen,
        );

  /* Services */

  final InviteRepository _inviteRepository;

  /* Fields */

  String _phoneNumber = "";
  String get phoneNumber => _phoneNumber;

  bool _isPhoneValid = false;
  bool get isPhoneValid => _isPhoneValid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void updatePhone(String phoneNumber) {
    updateUi(() {
      _phoneNumber = phoneNumber;
      _validatePhone(_phoneNumber);
    });
  }

  void _validatePhone(String phoneNumber) {
    final regExp = RegExp(AppConstants.phoneRegex);
    _isPhoneValid = regExp.hasMatch(phoneNumber);
  }

  /* Calls */

  Future<void> invitePatient() async {
    if (!isPhoneValid) {
      return showSnackbar(
        "Por favor, digite um número de telefone válido",
        InvitePatientEvent.showSnackbarError,
      );
    }

    updateUi(() => _isLoading = true);

    final (_, err) = await _inviteRepository.create(phoneNumber);
    if (err != null) {
      if (err is ApiPatientAlreadyWithDoctorError) {
        showSnackbar(
          "O paciente com o número informado já é seu paciente, portanto não precisa de convite",
          errorEvent,
        );
      } else if (err is ApiPatientNotRegisteredError) {
        emitEvent(InvitePatientEvent.openPatientNotRegisteredDialog);
      } else if (err is ApiInviteAlreadySentError) {
        showSnackbar("Você já enviou um convite para esse paciente", errorEvent);
      } else {
        handleDefaultErrors(err);
      }
      return updateUi(() => _isLoading = false);
    }

    showSnackbar(
      "Convite enviado com sucesso!",
      InvitePatientEvent.showSnackbarMessage,
    );
    emitEvent(InvitePatientEvent.closeSheet);

    updateUi(() => _isLoading = false);
  }
}
