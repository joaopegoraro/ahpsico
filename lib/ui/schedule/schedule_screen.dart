import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/booking/booking_screen.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/schedule/schedule_model.dart';
import 'package:ahpsico/ui/session/card/session_card.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const route = "/schedule";

  void _onEventEmitted(
    BuildContext context,
    ScheduleModel model,
    ScheduleEvent event,
  ) {
    switch (event) {
      case ScheduleEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case ScheduleEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case ScheduleEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
    }
  }

  Color _getStatusColor(Session session) => switch (session.status) {
        SessionStatus.canceled => AhpsicoColors.red,
        SessionStatus.concluded => AhpsicoColors.violet,
        SessionStatus.confirmed => AhpsicoColors.green,
        _ => AhpsicoColors.yellow,
      };

  String _getSessionStatus(Session session) => switch (session.status) {
        SessionStatus.canceled => "Cancelada",
        SessionStatus.concluded => "Concluída",
        SessionStatus.confirmed => "Confirmada",
        SessionStatus.notConfirmed => "Não confirmada",
        SessionStatus.confirmedByDoctor => "Não confirmada pelo paciente",
        SessionStatus.confirmedByPatient => "Não confirmada pela doutora",
      };

  static const _sessionMetadata = "session";

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: scheduleModelProvider,
      onEventEmitted: _onEventEmitted,
      onCreate: (model) {
        model.fetchScreenData();
      },
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Agenda",
          onBackPressed: context.pop,
        );
      },
      fabBuilder: (context, model) {
        if (model.user!.role.isDoctor) return null;
        return FloatingActionButton.extended(
          backgroundColor: AhpsicoColors.blue,
          label: const Text(
            "AGENDAR SESSÃO",
            style: AhpsicoText.tinyStyle,
          ),
          icon: const Icon(Icons.schedule),
          onPressed: () => context
              .push(BookingScreen.route)
              .then((_) => model.fetchScreenData()),
        );
      },
      bodyBuilder: (context, model) {
        return Calendar(
          startOnMonday: true,
          weekDays: const ['Dom', 'Seg', 'Ter', "Qua", "Qui", "Sex", "Sab"],
          eventsList: model.sessions.mapToList((session) {
            return NeatCleanCalendarEvent(
              model.user!.role.isDoctor ? session.user.name : "Doutora Andréa",
              description: "Status: ${_getSessionStatus(session)}",
              startTime: session.date,
              endTime: session.date.add(const Duration(hours: 1)),
              color: _getStatusColor(session),
              isDone: session.status == SessionStatus.concluded,
              metadata: {_sessionMetadata: session},
            );
          }),
          eventListBuilder: (context, events) {
            if (events.isEmpty) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Você não possui nenhuma sessão agendada para esse dia",
                    textAlign: TextAlign.center,
                    style: AhpsicoText.regular1Style
                        .copyWith(color: AhpsicoColors.dark75),
                  ),
                ),
              );
            }
            return Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final session =
                      events[index].metadata![_sessionMetadata] as Session;
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: index == events.length - 1 ? 32 : 0,
                    ),
                    child: SessionCard(
                      session: session,
                      onTap: (session) {
                        context.push(SessionDetail.route, extra: session);
                      },
                      isUserDoctor: model.user!.role.isDoctor,
                    ),
                  );
                },
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
