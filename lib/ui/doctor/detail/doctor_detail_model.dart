import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/doctor_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:flutter/services.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorDetailEvent {
  openEditProfileSheet,
  navigateToLoginScreen,
  showSnackbarMessage,
  showSnackbarError,
}

final doctorDetailModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final doctorRepository = ref.watch(doctorRepositoryProvider);
  return DoctorDetailModel(
    authService,
    userRepository,
    doctorRepository,
  );
});

class DoctorDetailModel extends BaseViewModel<DoctorDetailEvent> {
  DoctorDetailModel(
    super.authService,
    super.userRepository,
    this._doctorRepository,
  ) : super(
          errorEvent: DoctorDetailEvent.showSnackbarError,
          messageEvent: DoctorDetailEvent.showSnackbarMessage,
          navigateToLoginEvent: DoctorDetailEvent.navigateToLoginScreen,
        );

  /* Services */

  final DoctorRepository _doctorRepository;

  /* Fields */

  Doctor? _doctor;
  Doctor? get doctor => _doctor;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void openEditProfileSheet() {
    emitEvent(DoctorDetailEvent.openEditProfileSheet);
  }

  void addPixKeyToClipboard(String pixKey) {
    Clipboard.setData(ClipboardData(text: pixKey)).then((_) {
      showSnackbar(
        "Chave PIX copiada para área de transferência",
        DoctorDetailEvent.showSnackbarMessage,
      );
    });
  }

  void addPaymentDetailsToClipboard(String paymentDetails) {
    Clipboard.setData(ClipboardData(text: paymentDetails)).then((_) {
      showSnackbar(
        "Dados bancários copiados para área de transferência",
        DoctorDetailEvent.showSnackbarMessage,
      );
    });
  }

  void addPhoneToClipboard(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber)).then((_) {
      showSnackbar(
        "Telefone copiado para área de transferência",
        DoctorDetailEvent.showSnackbarMessage,
      );
    });
  }

  /* Calls */

  Future<void> fetchScreenData({required Doctor? doctor}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    if (doctor != null) {
      _doctor = doctor;
    } else {
      await _getDoctorData();
    }
    updateUi(() => _isLoading = false);
  }

  Future<void> _getDoctorData() async {
    try {
      await _doctorRepository.sync(user!.uid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    try {
      _doctor = await _doctorRepository.get(user!.uid);
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    }
  }
}
