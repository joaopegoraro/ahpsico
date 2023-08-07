import 'package:ahpsico/data/repositories/patient_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum PatientListEvent {
  openSendMessageSheet,
  openSearchBar,
  showSnackbarError,
  navigateToLogin,
}

final patientListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final patientRepository = ref.watch(patientRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PatientListModel(
    authService,
    userRepository,
    preferencesRepository,
    patientRepository,
  );
});

class PatientListModel extends BaseViewModel<PatientListEvent> {
  PatientListModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._patientRepository,
  ) : super(
          errorEvent: PatientListEvent.showSnackbarError,
          navigateToLoginEvent: PatientListEvent.navigateToLogin,
        );

  /* Services */

  final PatientRepository _patientRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<User> _patients = [];
  List<User> get patients => _patients;

  bool _selectMode = false;

  final List<String> _selectedPatientIds = [];
  List<String> get selectedPatientIds => _selectedPatientIds;

  bool get areAllPatientsSelected => selectedPatientIds.length == patients.length;

  bool get isSelectModeOn => _selectMode || selectedPatientIds.isNotEmpty;

  /* Methods */

  void enableSelectModeByDefault() {
    updateUi(() => _selectMode = true);
  }

  void selectPatient(User patient) {
    updateUi(() {
      if (!_selectedPatientIds.remove(patient.uuid)) {
        _selectedPatientIds.add(patient.uuid);
      }
    });
  }

  void selectAllPatients() {
    updateUi(() {
      _selectedPatientIds.clear();
      _selectedPatientIds.addAll(
        patients.map((patient) => patient.uuid),
      );
    });
  }

  void clearSelection() {
    updateUi(() {
      _selectedPatientIds.clear();
    });
  }

  void openSendMessageSheet() {
    if (_selectedPatientIds.isEmpty) {
      return showSnackbar(
        "Você precisa selecionar pelo menos um paciente para poder enviar uma mensagem",
        PatientListEvent.showSnackbarError,
      );
    }
    emitEvent(PatientListEvent.openSendMessageSheet);
  }

  void openSearchBar() {
    emitEvent(PatientListEvent.openSearchBar);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchPatients();
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchPatients() async {
    try {
      await _patientRepository.syncDoctorPatients(user!.uuid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    _patients = await _patientRepository.getDoctorPatients(user!.uuid);
  }
}
