import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/booking/booking_card.dart';
import 'package:ahpsico/ui/booking/booking_model.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/session/create_session/create_session_dialog.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:ahpsico/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({
    super.key,
    required this.doctor,
  });

  static const route = "/booking";

  final Doctor? doctor;

  static const _scheduleMetadata = "schedule";

  void _onEventEmitted(
    BuildContext context,
    BookingModel model,
    BookingEvent event,
  ) {
    switch (event) {
      case BookingEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case BookingEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case BookingEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case BookingEvent.navigateBack:
        context.pop(true);
      case BookingEvent.openScheduleAlreadyBookedDialog:
        AhpsicoDialog.show(
          context: context,
          content: "Já existe uma sessão agendada nesse horário, por isso não é possível desbloqueá-lo",
          firstButtonText: "Ok",
        );
      case BookingEvent.openSessionCreationDialog:
        showDialog(
          context: context,
          builder: (context) {
            return CreateSessionDialog(
              dateTime: model.selectedDate,
              onConfirm: (isMonthly) {
                context.pop();
                model.scheduleSession(
                  doctor: doctor!,
                  monthly: isMonthly,
                );
              },
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: bookingModelProvider,
      onEventEmitted: _onEventEmitted,
      onCreate: (model) {
        model.fetchScreenData(doctorUuid: doctor?.uuid);
      },
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: doctor == null ? "Horários" : "Agendamento",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        return Calendar(
          startOnMonday: false,
          hideTodayIcon: true,
          weekDays: const ['Dom', 'Seg', 'Ter', "Qua", "Qui", "Sex", "Sab"],
          onDateSelected: model.setSelectedDate,
          eventsList: model.schedule.mapToList((schedule) {
            return NeatCleanCalendarEvent(
              schedule.id.toString(),
              color: null,
              startTime: schedule.date,
              endTime: schedule.date.add(const Duration(hours: 1)),
              metadata: {_scheduleMetadata: schedule},
            );
          }),
          eventListBuilder: (context, events) {
            final selectedDay = DateTime(
              model.selectedDate.year,
              model.selectedDate.month,
              model.selectedDate.day,
            );
            final now = DateTime.now();

            if (!TimeUtils.areDatesSameDay(selectedDay, now) && selectedDay.isBefore(DateTime.now())) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "O dia selecionado já aconteceu",
                    textAlign: TextAlign.center,
                    style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark75),
                  ),
                ),
              );
            }

            final Map<int, DateTimeRange> blockedTimeRanges = Map.fromEntries(events.mapToList((event) {
              final schedule = event.metadata![_scheduleMetadata] as Schedule;
              final range = DateTimeRange(
                start: schedule.date,
                end: schedule.date.add(const Duration(hours: 1)),
              );
              return MapEntry(schedule.id, range);
            }));

            return Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                key: Key(model.selectedDate.toString()),
                crossAxisCount: 4,
                addAutomaticKeepAlives: false,
                children: [
                  ...model.availableSchedule.entries.map((availableBooking) {
                    return BookingCard(
                      booking: MapEntry(
                        availableBooking.key,
                        selectedDay.add(availableBooking.value),
                      ),
                      blockedTimeRanges: blockedTimeRanges,
                      onTapAvailable: (bookingTime) {
                        if (doctor == null) {
                          model.blockSchedule(bookingTime);
                        } else {
                          model.openSessionCreationDialog(bookingTime);
                        }
                      },
                      onTapBlocked: (blockedScheduleId) {
                        if (doctor == null) {
                          model.unblockSchedule(blockedScheduleId);
                        } else {
                          model.showBookingNotAvailableError();
                        }
                      },
                    );
                  }),
                ],
              ),
            );
          },
          isExpandable: true,
          isExpanded: true,
          eventDoneColor: AhpsicoColors.green,
          selectedColor: AhpsicoColors.violet,
          selectedTodayColor: AhpsicoColors.red,
          expandableDateFormat: "EEEE, dd MMMM",
          todayColor: AhpsicoColors.blue,
          locale: 'pt_BR',
          todayButtonText: 'Hoje',
          bottomBarTextStyle: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark75),
          displayMonthTextStyle: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark75),
          dayOfWeekStyle: AhpsicoText.tinyStyle.copyWith(color: AhpsicoColors.dark75),
        );
      },
    );
  }
}
