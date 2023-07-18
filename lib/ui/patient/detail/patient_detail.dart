import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/ui/advices/list/advices_list.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail.dart';
import 'package:ahpsico/ui/assignments/list/assignments_list.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/advice_card.dart';
import 'package:ahpsico/ui/components/assignment_card.dart';
import 'package:ahpsico/ui/components/home_button.dart';
import 'package:ahpsico/ui/components/session_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail_model.dart';
import 'package:ahpsico/ui/schedule/schedule_screen.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:ahpsico/ui/session/list/session_list.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientDetail extends StatelessWidget {
  const PatientDetail(
    this.patient, {
    super.key,
  });

  static const route = "/patient/detail";

  final Patient patient;

  void _onEventEmitted(
    BuildContext context,
    PatientDetailModel model,
    PatientDetailEvent event,
  ) {
    switch (event) {
      case PatientDetailEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case PatientDetailEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case PatientDetailEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: patientDetailModelProvider,
      onEventEmitted: _onEventEmitted,
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData(patientUuid: patient.uuid);
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Paciente",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        return ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: AhpsicoText.title2Style.copyWith(
                    color: AhpsicoColors.dark25,
                  ),
                ),
                AhpsicoSpacing.verticalSpaceRegular,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Telefone:",
                      style: AhpsicoText.regular2Style.copyWith(
                        color: AhpsicoColors.dark25,
                      ),
                    ),
                    AhpsicoSpacing.horizontalSpaceSmall,
                    Text(
                      MaskFormatters.phoneMaskFormatter.maskText(patient.phoneNumber),
                      style: AhpsicoText.title3Style.copyWith(
                        color: AhpsicoColors.dark25,
                      ),
                    ),
                  ],
                ),
                AhpsicoSpacing.verticalSpaceMedium,
                Row(
                  children: [
                    HomeButton(
                      text: "VER SESSÕES",
                      enableFlex: true,
                      color: AhpsicoColors.violet,
                      icon: Icons.groups,
                      onPressed: () => context.push(SessionList.route, extra: patient),
                    ),
                    AhpsicoSpacing.horizontalSpaceSmall,
                    HomeButton(
                      text: "VER TAREFAS",
                      enableFlex: true,
                      color: AhpsicoColors.green,
                      icon: Icons.home_work,
                      onPressed: () => context.push(AssignmentsList.route, extra: patient),
                    ),
                  ],
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
                    "Sessões agendadas com você",
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
                  "${patient.firstName} não possui nenhuma sessão agendada com você",
                  style: AhpsicoText.regular2Style.copyWith(
                    color: AhpsicoColors.dark25,
                  ),
                ),
              ),
            ...model.sessions.map((session) {
              return SessionCard(
                session: session,
                isUserDoctor: true,
                onTap: (session) => context.push(
                  SessionDetail.route,
                  extra: session,
                ),
              );
            }),
            AhpsicoSpacing.verticalSpaceLarge,
            if (model.assignments.isNotEmpty) ...[
              Text(
                "Mensagens enviadas por você",
                style: AhpsicoText.title3Style.copyWith(
                  color: AhpsicoColors.dark25,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              ...model.advices.map((advice) {
                return AdviceCard(
                  advice: advice,
                  showTitle: false,
                  isUserDoctor: true,
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
                  isUserDoctor: true,
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
