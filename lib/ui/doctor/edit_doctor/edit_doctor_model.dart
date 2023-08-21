import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum EditDoctorEvent {
  closeSheet,
  showSnackbarError,
  showSnackbarMessage,
  navigateToLoginScreen,
}

final editDoctorModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return EditDoctorModel(
    authService,
    userRepository,
    preferencesRepository,
  );
});

class EditDoctorModel extends BaseViewModel<EditDoctorEvent> {
  EditDoctorModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
  ) : super(
          errorEvent: EditDoctorEvent.showSnackbarError,
          navigateToLoginEvent: EditDoctorEvent.navigateToLoginScreen,
        );

  /* Services */

  /* Fields */

  String _name = "";
  String get name => _name;

  String _description = "";
  String get description => _description;

  String _crp = "";
  String get crp => _crp;

  String _pixKey = "";
  String get pixKey => _pixKey;

  String _paymentDetails = "";
  String get paymentDetails => _paymentDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void updateName(String name) {
    _name = name;
  }

  void updateDescription(String description) {
    _description = description;
  }

  void updateCrp(String crp) {
    _crp = crp;
  }

  void updatePixKey(String pixKey) {
    _pixKey = pixKey;
  }

  void updatePaymentDetails(String paymentDetails) {
    _paymentDetails = paymentDetails;
  }

  /* Calls */

  Future<void> editProfile() async {
    if (name.isEmpty) {
      return showSnackbar(
        "O campo de nome não pode ficar vazio",
        EditDoctorEvent.showSnackbarError,
      );
    }

    updateUi(() => _isLoading = true);

    await getUserData();

    final (_, err) = await userRepository.update(user!.copyWith(
      name: name.trim(),
      description: description.trim(),
      crp: crp.trim(),
      pixKey: pixKey.trim(),
      paymentDetails: paymentDetails.trim(),
    ));
    if (err != null) {
      await handleDefaultErrors(err);
      return updateUi(() => _isLoading = false);
    }

    showSnackbar(
      "Perfil editado com sucesso!",
      EditDoctorEvent.showSnackbarMessage,
    );
    emitEvent(EditDoctorEvent.closeSheet);

    updateUi(() => _isLoading = false);
  }
}
