import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/patient_repository.dart';
import 'package:ahpsico/data/repositories/schedule_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:collection/collection.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum BookingEvent {
  openScheduleAlreadyBookedDialog,
  openSessionCreationDialog,
  navigateToLoginScreen,
  navigateBack,
  showSnackbarMessage,
  showSnackbarError,
}

final bookingModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final patientRepository = ref.watch(patientRepositoryProvider);
  final scheduleRepository = ref.watch(scheduleRepositoryProvider);
  return BookingModel(
    authService,
    userRepository,
    sessionRepository,
    scheduleRepository,
    patientRepository,
  );
});

class BookingModel extends BaseViewModel<BookingEvent> {
  BookingModel(
    super.authService,
    super.userRepository,
    this._sessionRepository,
    this._scheduleRepository,
    this._patientRepository,
  ) : super(
          errorEvent: BookingEvent.showSnackbarError,
          messageEvent: BookingEvent.showSnackbarMessage,
          navigateToLoginEvent: BookingEvent.navigateToLoginScreen,
        );

  /* Services */

  final SessionRepository _sessionRepository;
  final ScheduleRepository _scheduleRepository;
  final PatientRepository _patientRepository;

  /* Utils */

  final Map<String, Duration> availableSchedule = const {
    "08:00": Duration(hours: 08),
    "08:30": Duration(hours: 08, minutes: 30),
    "09:00": Duration(hours: 09),
    "09:30": Duration(hours: 09, minutes: 30),
    "10:00": Duration(hours: 10),
    "10:30": Duration(hours: 10, minutes: 30),
    "11:00": Duration(hours: 11),
    "11:30": Duration(hours: 11, minutes: 30),
    "13:00": Duration(hours: 13),
    "13:30": Duration(hours: 13, minutes: 30),
    "14:00": Duration(hours: 14),
    "14:30": Duration(hours: 14, minutes: 30),
    "15:00": Duration(hours: 15),
    "15:30": Duration(hours: 15, minutes: 30),
    "16:00": Duration(hours: 16),
    "16:30": Duration(hours: 16, minutes: 30),
    "17:00": Duration(hours: 17),
    "17:30": Duration(hours: 17, minutes: 30),
    "18:00": Duration(hours: 18),
    "18:30": Duration(hours: 18, minutes: 30),
    "19:00": Duration(hours: 19),
    "19:30": Duration(hours: 19, minutes: 30),
    "20:00": Duration(hours: 20),
    "20:30": Duration(hours: 20, minutes: 30),
  };

  /* Fields */

  Patient? _patient;
  Patient? get patient => _patient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _newSessionTime;
  DateTime? get newSessionTime => _newSessionTime;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<Schedule> _schedule = [];
  List<Schedule> get schedule => _schedule;

  /* Methods */

  void setSelectedDate(DateTime date) {
    updateUi(() {
      _selectedDate = date;
    });
  }

  void openSessionCreationDialog(DateTime sessionTime) {
    _newSessionTime = sessionTime;
    emitEvent(BookingEvent.openSessionCreationDialog);
  }

  void showBookingNotAvailableError() {
    showSnackbar(
      "O horário selecionado não está disponível",
      BookingEvent.showSnackbarError,
    );
  }

  /* Calls */

  Future<void> scheduleSession({
    required Doctor doctor,
    required bool monthly,
  }) async {
    updateUi(() => _isLoading = true);

    final newSessions = <Session>[];

    if (monthly) {
      for (int index = 0; index < 4; index++) {
        final newSession = Session(
          id: 0,
          doctor: doctor,
          patient: patient!,
          groupIndex: index,
          status: SessionStatus.notConfirmed,
          type: SessionType.monthly,
          date: _newSessionTime!.add(Duration(days: 7 * index)),
        );
        newSessions.add(newSession);
      }
    } else {
      final newSession = Session(
        id: 0,
        doctor: doctor,
        patient: patient!,
        groupIndex: 0,
        status: SessionStatus.notConfirmed,
        type: SessionType.individual,
        date: _newSessionTime!,
      );
      newSessions.add(newSession);
    }

    try {
      for (final session in newSessions) {
        await _sessionRepository.create(session);
      }
      showSnackbar(
        monthly ? "Sessões agendadas com sucesso!" : "Sessão agendada com sucesso!",
        BookingEvent.showSnackbarMessage,
      );
      emitEvent(BookingEvent.navigateBack);
    } on ApiSessionAlreadyBookedException catch (_) {
      showSnackbar(
        "Ops! Parece que o horário escolhido não está mais disponível",
        BookingEvent.showSnackbarError,
      );
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    updateUi(() => _isLoading = false);
  }

  Future<void> blockSchedule(DateTime blockTime) async {
    updateUi(() => _isLoading = true);

    final newBlockedSchedule = Schedule(
      id: 0,
      doctorUuid: user!.uid,
      date: blockTime,
      isSession: false,
    );

    try {
      await _scheduleRepository.create(newBlockedSchedule);
      showSnackbar(
        "Horário bloqueado com sucesso!",
        BookingEvent.showSnackbarMessage,
      );
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    updateUi(() => _isLoading = false);
  }

  Future<void> unblockSchedule(int blockedScheduleId) async {
    updateUi(() => _isLoading = true);

    final blockedSchedule = schedule.firstWhereOrNull((item) {
      return item.id == blockedScheduleId;
    });
    if (blockedSchedule?.isSession == true) {
      updateUi(() => _isLoading = false);
      return emitEvent(BookingEvent.openScheduleAlreadyBookedDialog);
    }

    try {
      await _scheduleRepository.delete(blockedScheduleId);
      showSnackbar(
        "Horário desbloqueado com sucesso!",
        BookingEvent.showSnackbarMessage,
      );
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    updateUi(() => _isLoading = false);
  }

  Future<void> fetchScreenData({required String? doctorUuid}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    if (doctorUuid != null) {
      _getPatientData();
    }
    await _getSchedules(doctorUuid: doctorUuid);
    updateUi(() => _isLoading = false);
  }

  Future<void> _getPatientData() async {
    try {
      _patient = await _patientRepository.get(user!.uid);
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    }
  }

  Future<void> _getSchedules({required String? doctorUuid}) async {
    final userUid = user!.uid;
    try {
      _schedule = await _scheduleRepository.getDoctorSchedule(doctorUuid ?? userUid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
      emitEvent(BookingEvent.navigateBack);
    }
  }
}
