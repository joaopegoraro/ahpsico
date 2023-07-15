import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
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
  return SignUpModel(userRepository, authService);
});

class SignUpModel extends ViewModel<SignUpEvent> {
  SignUpModel(
    this._userRepository,
    this._authService,
  );

  /* Services */

  final UserRepository _userRepository;
  final AuthService _authService;

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
    await _userRepository.clear();
    await _authService.signOut();
    showSnackbar(
      message ?? "Cadastro cancelado :(",
      SignUpEvent.showSnackbarMessage,
    );
    emitEvent(SignUpEvent.navigateToLogin);
  }

  Future<void> completeSignUp() async {
    updateUi(() => _isLoadingSignUp = true);

    try {
      final user = User(
        uid: "Not necessary for the sign up proccess, "
            "the backend picks this up from the authorization token sent in the request header",
        phoneNumber: "Not necessary for the sign up proccess, "
            "the backend picks this up from the authorization token sent in the request header",
        name: name.trim(),
        isDoctor: isDoctor,
      );
      final newUser = await _userRepository.create(user);
      showSnackbar(
        "Cadastro bem sucedido! Bem vindo(a) ${newUser.name}!",
        SignUpEvent.showSnackbarMessage,
      );
      if (newUser.isDoctor) {
        emitEvent(SignUpEvent.navigateToDoctorHome);
      } else {
        emitEvent(SignUpEvent.navigateToPatientHome);
      }
      updateUi(() => _isLoadingSignUp = true);
    } on ApiUserAlreadyRegisteredException catch (_) {
      await cancelSignUp(message: "Ops! Parece que você já possui uma conta. Tente fazer login novamente");
    } on ApiConnectionException catch (_) {
      showSnackbar(
        "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet",
        SignUpEvent.showSnackbarError,
      );
    }

    updateUi(() => _isLoadingSignUp = false);
  }
}
