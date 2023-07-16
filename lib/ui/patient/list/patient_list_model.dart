import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/patient_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum PatientListEvent {
  showSnackbarError,
  navigateToLogin,
}

final patientListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final patientRepository = ref.watch(patientRepositoryProvider);
  return PatientListModel(
    authService,
    userRepository,
    patientRepository,
  );
});

class PatientListModel extends BaseViewModel<PatientListEvent> {
  PatientListModel(
    super.authService,
    super.userRepository,
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

  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  List<String> _selectedPatientIds = [];
  List<String> get selectedPatientIds => _selectedPatientIds;

  /* Methods */

  void selectPatient(Patient patient) {
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
    updateUi(() => _selectedPatientIds.clear());
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);

    // TODO REMOVE THIS LINE
    user = const User(
      uid: "some uid",
      name: "Andréa Hahmeyer Pegoraro",
      phoneNumber: "",
      isDoctor: true,
    );
    _patients = _mockpatients;
    return updateUi(() => _isLoading = false);

    await getUserData();
    await _fetchPatients();
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchPatients() async {
    try {
      await _patientRepository.syncDoctorPatients(user!.uid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    _patients = await _patientRepository.getDoctorPatients(user!.uid);
  }
}

const _mockpatients = <Patient>[
  Patient(
    uuid: "some uid",
    name: "Mário Garcia",
    phoneNumber: "99999999999",
  ),
  Patient(
    uuid: "some uid",
    name: "Júlia Rosa",
    phoneNumber: "99999999999",
  ),
  Patient(
    uuid: "some uid",
    name: "Carol Silva",
    phoneNumber: "99999999999",
  ),
  Patient(
    uuid: "some uid",
    name: "Gabriela Pereira",
    phoneNumber: "99999999999",
  ),
];
