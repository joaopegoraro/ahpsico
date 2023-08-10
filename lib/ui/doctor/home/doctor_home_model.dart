import 'package:ahpsico/data/repositories/patient_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorHomeEvent {
  openInvitePatientBottomSheet,
  openLogoutDialog,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final doctorHomeModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final patientRepository = ref.watch(patientRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return DoctorHomeModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
    patientRepository,
  );
});

class DoctorHomeModel extends BaseViewModel<DoctorHomeEvent> {
  DoctorHomeModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
    this._patientRepository,
  ) : super(
          errorEvent: DoctorHomeEvent.showSnackbarError,
          messageEvent: DoctorHomeEvent.showSnackbarMessage,
          navigateToLoginEvent: DoctorHomeEvent.navigateToLoginScreen,
        );

  /* Services */
  final SessionRepository _sessionRepository;
  final PatientRepository _patientRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  /* Methods */

  void openLogoutDialog() {
    emitEvent(DoctorHomeEvent.openLogoutDialog);
  }

  void openInvitePatientSheet() {
    emitEvent(DoctorHomeEvent.openInvitePatientBottomSheet);
  }

  /* Calls */

  Future<void> fetchScreenData({bool sync = true}) async {
    updateUi(() => _isLoading = sync);
    await getUserData(sync: sync);

    if (sync) {
      await _syncDoctorPatients();
    }

    await _getTodaySessions(sync: sync);
    updateUi(() => _isLoading = false);
  }

  Future<void> _getTodaySessions({bool sync = true}) async {
    final userUid = user!.uuid;
    final now = DateTime.now();

    if (sync) {
      final err = await _sessionRepository.syncDoctorSessions(userUid, date: now);
      if (err != null) {
        return await handleDefaultErrors(err);
      }
    }

    _sessions = await _sessionRepository.getDoctorSessions(userUid, date: now);
  }

  Future<void> _syncDoctorPatients() async {
    final err = await _patientRepository.syncDoctorPatients(user!.uuid);
    if (err != null) {
      return await handleDefaultErrors(err);
    }
  }
}
