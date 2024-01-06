import 'package:ahpsico/constants/session_payment_type.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/session_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/constants/session_payment_status.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/constants/session_type.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum BookingEvent {
  openScheduleAlreadyBookedDialog,
  openSessionCreationDialog,
  openRescheduleSessionDialog,
  navigateToLoginScreen,
  navigateBack,
  showSnackbarMessage,
  showSnackbarError,
}

final bookingModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return BookingModel(
    authService,
    userRepository,
    preferencesRepository,
    sessionRepository,
  );
});

class BookingModel extends BaseViewModel<BookingEvent> {
  BookingModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._sessionRepository,
  ) : super(
          errorEvent: BookingEvent.showSnackbarError,
          messageEvent: BookingEvent.showSnackbarMessage,
          navigateToLoginEvent: BookingEvent.navigateToLoginScreen,
        );

  /* Services */

  final SessionRepository _sessionRepository;

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
    "12:00": Duration(hours: 12),
    "12:30": Duration(hours: 12, minutes: 30),
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingFetchData = false;
  bool get isLoadingFetchData => _isLoadingFetchData;

  DateTime? _newSessionTime;
  DateTime? get newSessionTime => _newSessionTime;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

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

  void openRescheduleSessionDialog(DateTime sessionTime) {
    _newSessionTime = sessionTime;
    emitEvent(BookingEvent.openRescheduleSessionDialog);
  }

  void showBookingNotAvailableError() {
    showSnackbar(
      "O horário selecionado não está disponível",
      BookingEvent.showSnackbarError,
    );
  }

  /* Calls */

  Future<List<Session>> scheduleSession({
    String? message,
    required SessionPaymentType paymentType,
    required SessionType sessionType,
  }) async {
    updateUi(() => _isLoading = true);

    final newSessions = <Session>[];

    if (sessionType.isMonthly) {
      for (int index = 0; index < 4; index++) {
        final newSession = Session(
          id: 0,
          user: user!,
          date: _newSessionTime!.add(Duration(days: 7 * index)),
          groupIndex: index,
          status: SessionStatus.notConfirmed,
          type: sessionType,
          paymentStatus:
              paymentType.isParticular ? SessionPaymentStatus.notPayed : null,
          paymentType: paymentType,
          updatedBy: user!.role,
          updatedAt: DateTime.now(),
          updateMessage: message,
        );
        newSessions.add(newSession);
      }
    } else {
      final newSession = Session(
        id: 0,
        user: user!,
        date: _newSessionTime!,
        groupIndex: 0,
        status: SessionStatus.notConfirmed,
        type: sessionType,
        paymentStatus:
            paymentType.isParticular ? SessionPaymentStatus.notPayed : null,
        paymentType: paymentType,
        updatedBy: user!.role,
        updatedAt: DateTime.now(),
        updateMessage: message,
      );
      newSessions.add(newSession);
    }

    ApiError? err;
    for (final session in newSessions) {
      (_, err) = await _sessionRepository.create(session);
      if (err is ApiSessionAlreadyBookedError) {
        showSnackbar(
          "Ops! Parece que o horário escolhido não está mais disponível",
          BookingEvent.showSnackbarError,
        );
        updateUi(() => _isLoading = false);
        return [];
      } else if (err != null) {
        await handleDefaultErrors(err);
        updateUi(() => _isLoading = false);
        return [];
      }
    }

    showSnackbar(
      sessionType.isMonthly
          ? "Sessões agendadas com sucesso!"
          : "Sessão agendada com sucesso!",
      BookingEvent.showSnackbarMessage,
    );
    updateUi(() => _isLoading = false);

    return newSessions;
  }

  Future<Session?> rescheduleSession({
    String? message,
    required Session session,
  }) async {
    updateUi(() => _isLoading = true);

    final updatedSession = session.copyWith(
      date: _newSessionTime!,
      status: SessionStatus.notConfirmed,
      updateMessage: message,
      updatedBy: user!.role,
    );

    final (result, err) = await _sessionRepository.update(updatedSession);
    if (err is ApiSessionAlreadyBookedError) {
      showSnackbar(
        "Ops! Parece que o horário escolhido não está mais disponível",
        BookingEvent.showSnackbarError,
      );
      updateUi(() => _isLoading = false);
      return null;
    } else if (err != null) {
      await handleDefaultErrors(err);
      updateUi(() => _isLoading = false);
      return null;
    }

    showSnackbar(
      "Sessão remarcada com sucesso!",
      BookingEvent.showSnackbarMessage,
    );
    updateUi(() => _isLoading = false);
    return result;
  }

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoadingFetchData = true);
    await getUserData();
    updateUi(() => _isLoadingFetchData = false);
  }
}
