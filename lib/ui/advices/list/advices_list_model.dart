import 'package:ahpsico/data/repositories/advice_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum AdviceListEvent {
  openDeleteConfirmationDialog,
  showSnackbarError,
  navigateToLogin,
}

final adviceListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final adviceRepository = ref.watch(adviceRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return AdviceListModel(
    authService,
    userRepository,
    preferencesRepository,
    adviceRepository,
  );
});

class AdviceListModel extends BaseViewModel<AdviceListEvent> {
  AdviceListModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._adviceRepository,
  ) : super(
          errorEvent: AdviceListEvent.showSnackbarError,
          navigateToLoginEvent: AdviceListEvent.navigateToLogin,
        );

  /* Services */

  final AdviceRepository _adviceRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Advice> _advices = [];
  List<Advice> get advices => _advices;

  final List<int> _selectedAdvicesIds = [];
  List<int> get selectedAdvicesIds => _selectedAdvicesIds;

  bool get areAllAdvicesSelected => selectedAdvicesIds.length == advices.length;

  bool get isSelectModeOn => selectedAdvicesIds.isNotEmpty;

  /* Methods */

  void openDeleteConfirmationDialog() {
    emitEvent(AdviceListEvent.openDeleteConfirmationDialog);
  }

  void selectAdvice(Advice advice) {
    updateUi(() {
      if (!_selectedAdvicesIds.remove(advice.id)) {
        _selectedAdvicesIds.add(advice.id);
      }
    });
  }

  void clearSelection() {
    updateUi(() {
      _selectedAdvicesIds.clear();
    });
  }

  /* Calls */

  Future<void> fetchScreenData({required String? patientUuid}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchAdvices(patientUuid: patientUuid);
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchAdvices({required String? patientUuid}) async {
    try {
      if (patientUuid != null) {
        await _adviceRepository.syncPatientAdvices(patientUuid);
      } else {
        await _adviceRepository.syncDoctorAdvices(user!.uuid);
      }
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    if (patientUuid != null) {
      _advices = await _adviceRepository.getPatientAdvices(patientUuid);
    } else {
      _advices = await _adviceRepository.getDoctorAdvices(user!.uuid);
    }
  }

  Future<void> deleteSelectedAdvices() async {
    updateUi(() => _isLoading = true);
    try {
      for (final adviceId in _selectedAdvicesIds) {
        await _adviceRepository.delete(adviceId);
      }
      clearSelection();
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }
    updateUi(() => _isLoading = false);
  }
}
