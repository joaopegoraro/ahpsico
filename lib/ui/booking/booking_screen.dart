import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
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

  static const Map<String, Duration> availableSchedule = {
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
        context.pop();
        context.pop();
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
          startOnMonday: true,
          weekDays: const ['Dom', 'Seg', 'Ter', "Qua", "Qui", "Sex", "Sab"],
          onDateSelected: model.setSelectedDate,
          eventsList: model.schedule.mapToList((schedule) {
            return NeatCleanCalendarEvent(
              schedule.id.toString(),
              startTime: schedule.date,
              endTime: schedule.date.add(const Duration(hours: 1)),
              metadata: {_scheduleMetadata: schedule},
            );
          }),
          dayBuilder: (context, day) {},
          eventListBuilder: (context, events) {
            final selectedDay = DateTime(
              model.selectedDate.year,
              model.selectedDate.month,
              model.selectedDate.day,
            );

            final Map<int, DateTimeRange> blockedTimeRanges = Map.fromEntries(events.mapToList((event) {
              final schedule = event.metadata![_scheduleMetadata] as Schedule;
              final range = DateTimeRange(
                start: schedule.date,
                end: schedule.date.add(const Duration(hours: 1)),
              );
              return MapEntry(schedule.id, range);
            }));

            return Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              color: AhpsicoColors.red,
                            ),
                            AhpsicoSpacing.horizontalSpaceTiny,
                            Text(
                              doctor == null ? "Horário bloqueado" : "Horário indisponível",
                              style: AhpsicoText.tinyStyle.copyWith(
                                color: AhpsicoColors.dark75,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              color: AhpsicoColors.blue,
                            ),
                            AhpsicoSpacing.horizontalSpaceTiny,
                            Text(
                              "Horário disponível",
                              style: AhpsicoText.tinyStyle.copyWith(
                                color: AhpsicoColors.dark75,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    itemCount: availableSchedule.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      final availableBooking = availableSchedule.entries.elementAt(index);
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: index == events.length - 1 ? 32 : 0,
                        ),
                        child: BookingCard(
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
                        ),
                      );
                    },
                  ),
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
          eventColor: null,
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
