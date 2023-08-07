import 'package:ahpsico/data/repositories/doctor_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorListEvent {
  showSnackbarError,
  navigateToLogin,
}

final doctorListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final doctorRepository = ref.watch(doctorRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return DoctorListModel(
    authService,
    userRepository,
    preferencesRepository,
    doctorRepository,
  );
});

class DoctorListModel extends BaseViewModel<DoctorListEvent> {
  DoctorListModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._doctorRepository,
  ) : super(
          errorEvent: DoctorListEvent.showSnackbarError,
          navigateToLoginEvent: DoctorListEvent.navigateToLogin,
        );

  /* Services */

  final DoctorRepository _doctorRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<User> _doctors = [];
  List<User> get doctors => _doctors;

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchDoctors();
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchDoctors() async {
    try {
      await _doctorRepository.syncPatientDoctors(user!.uuid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    _doctors = await _doctorRepository.getPatientDoctors(user!.uuid);
  }
}
