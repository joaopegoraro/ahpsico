import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum SignUpEvent {
  navigateToLogin,
  navigateToDoctorHome,
  navigateToPatientHome,
  openCancelationDialog,
  openConfirmationDialog,
  showSnackbarError,
  showSnackbarMessage,
}

final signUpModelProvider = ViewModelProviderFactory.create((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return SignUpModel(
    authService,
    userRepository,
    preferencesRepository,
  );
});

class SignUpModel extends BaseViewModel<SignUpEvent> {
  SignUpModel(
    super.userRepository,
    super.authService,
    super.preferencesRepository,
  ) : super(
          errorEvent: SignUpEvent.showSnackbarError,
          messageEvent: SignUpEvent.showSnackbarMessage,
          navigateToLoginEvent: SignUpEvent.navigateToLogin,
        );

  /* Services */

  /* Fields */

  bool _isLoadingSignUp = false;
  bool get isLoadingSignUp => _isLoadingSignUp;

  String _name = "";
  String get name => _name;
  bool get isNameValid => name.length < 150;

  bool _isDoctor = false;
  bool get isDoctor => _isDoctor;

  /* Methods */

  void updateName(String name) {
    _name = name;
  }

  void openCancelationDialog() {
    emitEvent(SignUpEvent.openCancelationDialog);
  }

  void openConfirmationDialog({required bool isDoctor}) {
    if (name.trim().isEmpty) {
      return showSnackbar(
        "Preencha o campo com o seu nome para continuar",
        SignUpEvent.showSnackbarError,
      );
    }
    if (isNameValid) {
      _isDoctor = isDoctor;
      return emitEvent(SignUpEvent.openConfirmationDialog);
    }
    return showSnackbar(
      "O seu nome é muito grande, por favor informe um nome que tenha menos de 150 caracteres",
      SignUpEvent.showSnackbarError,
    );
  }

  /* Calls */

  Future<void> cancelSignUp({String? message}) async {
    await userRepository.clear();
    await authService.signOut();
    showSnackbar(
      message ?? "Cadastro cancelado :(",
      SignUpEvent.showSnackbarMessage,
    );
    emitEvent(SignUpEvent.navigateToLogin);
  }

  Future<void> completeSignUp() async {
    updateUi(() => _isLoadingSignUp = true);

    final (newUser, err) = await userRepository.create(
      name.trim(),
      isDoctor ? UserRole.doctor : UserRole.patient,
    );
    if (err != null) {
      if (err is ApiUserAlreadyRegisteredError) {
        await cancelSignUp(
            message: "Ops! Parece que você já possui uma conta. Tente fazer login novamente");
      } else {
        await handleDefaultErrors(err);
      }
      return updateUi(() => _isLoadingSignUp = false);
    }
    showSnackbar(
      "Cadastro bem sucedido! Bem vindo(a) ${newUser!.name}!",
      SignUpEvent.showSnackbarMessage,
    );
    if (newUser.role.isDoctor) {
      emitEvent(SignUpEvent.navigateToDoctorHome);
    } else {
      emitEvent(SignUpEvent.navigateToPatientHome);
    }

    updateUi(() => _isLoadingSignUp = false);
  }
}
