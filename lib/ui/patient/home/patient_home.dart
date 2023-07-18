import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail.dart';
import 'package:ahpsico/ui/assignments/list/assignments_list.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/advice_card.dart';
import 'package:ahpsico/ui/components/assignment_card.dart';
import 'package:ahpsico/ui/components/dialogs/logout_dialog.dart';
import 'package:ahpsico/ui/components/home_button.dart';
import 'package:ahpsico/ui/components/home_topbar.dart';
import 'package:ahpsico/ui/components/session_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail.dart';
import 'package:ahpsico/ui/patient/home/patient_home_model.dart';
import 'package:ahpsico/ui/schedule/schedule_screen.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:ahpsico/ui/session/list/session_list.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHome extends StatelessWidget {
  const PatientHome({super.key});

  static const route = "/patient/home";

  void _onEventEmitted(
    BuildContext context,
    PatientHomeModel model,
    PatientHomeEvent event,
  ) {
    switch (event) {
      case PatientHomeEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case PatientHomeEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case PatientHomeEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case PatientHomeEvent.openLogoutDialog:
        showDialog(
          context: context,
          builder: (context) => LogoutDialog(
            onLogout: () {
              model.logout();
              context.pop();
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: patientHomeModelProvider,
      onEventEmitted: _onEventEmitted,
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData();
      },
      topbarBuilder: (context, model) {
        return HomeTopbar(
          userName: model.user!.firstName,
          goToProfile: () {
            // TODO
          },
          logout: model.openLogoutDialog,
        );
      },
      bodyBuilder: (context, model) {
        return ListView(
          children: [
            if (model.sessions.isNotEmpty) ...[
              Text(
                "Você possui",
                style: AhpsicoText.regular3Style.copyWith(
                  color: AhpsicoColors.light20,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              Text(
                "${model.sessions.length} sessões agendadas",
                style: AhpsicoText.title1Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceMedium,
            ],
            Row(
              children: [
                HomeButton(
                  text: "VER SESSÕES",
                  enableFlex: true,
                  color: AhpsicoColors.violet,
                  icon: Icons.groups,
                  onPressed: () => context.push(SessionList.route),
                ),
                AhpsicoSpacing.horizontalSpaceSmall,
                HomeButton(
                  text: "VER TAREFAS",
                  enableFlex: true,
                  color: AhpsicoColors.green,
                  icon: Icons.home_work,
                  onPressed: () => context.push(AssignmentsList.route),
                ),
              ],
            ),
            AhpsicoSpacing.verticalSpaceMedium,
            TextButton(
              onPressed: () => context.push(ScheduleScreen.route),
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                )),
              ),
              child: Row(
                children: [
                  Text(
                    "Sessões agendadas",
                    style: AhpsicoText.title3Style.copyWith(
                      color: AhpsicoColors.dark25,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
            AhpsicoSpacing.verticalSpaceSmall,
            if (model.sessions.isEmpty)
              Center(
                child: Text(
                  "Você não possui nenhuma sessão agendada",
                  style: AhpsicoText.regular2Style.copyWith(
                    color: AhpsicoColors.dark25,
                  ),
                ),
              ),
            ...model.sessions.map((session) {
              return SessionCard(
                session: session,
                isUserDoctor: false,
                onTap: (session) => context.push(
                  SessionDetail.route,
                  extra: session,
                ),
              );
            }),
            AhpsicoSpacing.verticalSpaceLarge,
            if (model.assignments.isNotEmpty) ...[
              Text(
                "Mensagens recebidas",
                style: AhpsicoText.title3Style.copyWith(
                  color: AhpsicoColors.dark25,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              ...model.advices.map((advice) {
                return AdviceCard(
                  advice: advice,
                  showTitle: true,
                  isUserDoctor: false,
                );
              }),
            ],
            AhpsicoSpacing.verticalSpaceLarge,
            if (model.assignments.isNotEmpty) ...[
              Text(
                "Tarefas pendentes",
                style: AhpsicoText.title3Style.copyWith(
                  color: AhpsicoColors.dark25,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              ...model.assignments.map((assignment) {
                return AssignmentCard(
                  assignment: assignment,
                  isUserDoctor: false,
                  onTap: (assignment) => context.push(
                    AssignmentDetail.route,
                    extra: assignment,
                  ),
                );
              }),
            ],
            AhpsicoSpacing.verticalSpaceLarge,
          ].mapToList((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: item,
            );
          }),
        );
      },
    );
  }
}
