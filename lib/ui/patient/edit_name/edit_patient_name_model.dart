import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum EditPatientNameEvent {
  closeSheet,
  showSnackbarError,
  showSnackbarMessage,
  navigateToLoginScreen,
}

final editPatientNameModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return EditPatientNameModel(
    authService,
    userRepository,
    preferencesRepository,
  );
});

class EditPatientNameModel extends BaseViewModel<EditPatientNameEvent> {
  EditPatientNameModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
  ) : super(
          errorEvent: EditPatientNameEvent.showSnackbarError,
          navigateToLoginEvent: EditPatientNameEvent.navigateToLoginScreen,
        );

  /* Fields */

  String _name = "";
  String get name => _name;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void updateName(String name) {
    _name = name;
  }

  /* Calls */

  Future<void> confirmUpdateName({required User patient}) async {
    if (patient.name == name) {
      return emitEvent(EditPatientNameEvent.closeSheet);
    }

    updateUi(() => _isLoading = true);

    if (name.isEmpty) {
      return showSnackbar(
        "O nome não pode ficar vazio!",
        EditPatientNameEvent.showSnackbarError,
      );
    }

    try {
      await userRepository.update(patient.copyWith(name: name));
      showSnackbar(
        "Nome alterado com sucesso!",
        EditPatientNameEvent.showSnackbarMessage,
      );
      emitEvent(EditPatientNameEvent.closeSheet);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    updateUi(() => _isLoading = false);
  }
}
