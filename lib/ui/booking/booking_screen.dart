import 'package:ahpsico/models/session.dart';
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
import 'package:ahpsico/utils/time_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({
    super.key,
    required this.session,
  });

  static const route = "/booking";
  static const sessionArgkey = "session";

  static Map<String, dynamic> buildArgs({Session? session}) {
    return {sessionArgkey: session};
  }

  final Session? session;

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
      case BookingEvent.openScheduleAlreadyBookedDialog:
        AhpsicoDialog.show(
          context: context,
          content: "O horário selecionado não está disponível",
          firstButtonText: "Ok",
        );
      case BookingEvent.openRescheduleSessionDialog:
        if (model.newSessionTime != null) {
          AhpsicoDialog.show(
            context: context,
            content: "Tem certeza que deseja remarcar a sessão para "
                "${TimeUtils.getReadableDate(model.newSessionTime!)}, "
                "às ${TimeUtils.getDateAsHours(model.newSessionTime!)}?",
            firstButtonText: "Sim, tenho certeza",
            secondButtonText: "Cancelar",
            onTapFirstButton: () {
              context.pop();
              model.rescheduleSession(session: session!).then((updatedSession) {
                if (updatedSession != null) {
                  context.go(LoginScreen.route);
                }
              });
            },
          );
        }
      case BookingEvent.openSessionCreationDialog:
        if (model.newSessionTime != null) {
          showDialog(
            context: context,
            builder: (context) {
              return CreateSessionDialog(
                dateTime: model.newSessionTime!,
                onConfirm: (message, paymentType, sessionType) {
                  context.pop();
                  model
                      .scheduleSession(
                          message: message,
                          paymentType: paymentType,
                          sessionType: sessionType)
                      .then((updatedSessions) {
                    if (updatedSessions.isNotEmpty) {
                      context.go(LoginScreen.route);
                    }
                  });
                },
              );
            },
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: bookingModelProvider,
      onEventEmitted: _onEventEmitted,
      onCreate: (model) {
        model.fetchScreenData();
      },
      shouldShowLoading: (context, model) {
        return model.isLoadingFetchData || model.user == null;
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: session != null ? "Remarcar" : "Agendamento",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        return Calendar(
          startOnMonday: false,
          hideTodayIcon: true,
          weekDays: const ['Dom', 'Seg', 'Ter', "Qua", "Qui", "Sex", "Sab"],
          onDateSelected: model.setSelectedDate,
          eventListBuilder: (context, events) {
            final selectedDay = DateTime(
              model.selectedDate.year,
              model.selectedDate.month,
              model.selectedDate.day,
            );
            final now = DateTime.now();

            if (!TimeUtils.areDatesSameDay(selectedDay, now) &&
                selectedDay.isBefore(DateTime.now())) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "O dia selecionado já aconteceu",
                    textAlign: TextAlign.center,
                    style: AhpsicoText.regular1Style
                        .copyWith(color: AhpsicoColors.dark75),
                  ),
                ),
              );
            }

            return Expanded(
              child: Stack(
                children: [
                  GridView.count(
                    padding: const EdgeInsets.all(16),
                    key: Key(model.selectedDate.toString() +
                        model.availableSchedule.length.toString()),
                    crossAxisCount: 4,
                    addAutomaticKeepAlives: false,
                    children: [
                      ...model.availableSchedule.entries
                          .whereNot((availableBooking) {
                        return selectedDay
                            .add(availableBooking.value)
                            .isBefore(now.add(const Duration(hours: 3)));
                      }).map((availableBooking) {
                        return BookingCard(
                          booking: MapEntry(
                            availableBooking.key,
                            selectedDay.add(availableBooking.value),
                          ),
                          onTapAvailable: (bookingTime) {
                            if (session != null) {
                              model.openRescheduleSessionDialog(bookingTime);
                            } else {
                              model.openSessionCreationDialog(bookingTime);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                  if (model.isLoading)
                    Container(
                      color: Colors.grey.withOpacity(0.8),
                      width: double.infinity,
                      height: double.infinity,
                      child: const Center(child: CircularProgressIndicator()),
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
          locale: 'pt_BR',
          todayButtonText: 'Hoje',
          bottomBarTextStyle:
              AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark75),
          displayMonthTextStyle:
              AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark75),
          dayOfWeekStyle:
              AhpsicoText.tinyStyle.copyWith(color: AhpsicoColors.dark75),
        );
      },
    );
  }
}
