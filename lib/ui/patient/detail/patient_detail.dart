import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/assignments/create_assignment/create_assignment_sheet.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail.dart';
import 'package:ahpsico/ui/assignments/list/assignments_list.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/advices/card/advice_card.dart';
import 'package:ahpsico/ui/assignments/card/assignment_card.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/expandable_fab.dart';
import 'package:ahpsico/ui/components/home_button.dart';
import 'package:ahpsico/ui/session/card/session_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail_model.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:ahpsico/ui/session/list/session_list.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDetail extends StatelessWidget {
  const PatientDetail(
    this.patient, {
    super.key,
  });

  static const route = "/patient/detail";

  final User patient;

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
      case PatientDetailEvent.openCreateAssignmentSheet:
        AhpsicoSheet.show(
          context: context,
          builder: (context) {
            return CreateAssignmentSheet(patient: patient);
          },
        ).then((shouldRefresh) {
          if (shouldRefresh == true) {
            model.fetchScreenData(patientUuid: patient.uuid);
          }
        });
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
      fabBuilder: (context, model) {
        return ExpandableFab(
          distance: 112,
          children: [
            InkWell(
              onTap: () {
                launchUrl(Uri.parse("https://wa.me/${patient.phoneNumber}"));
              },
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Material(
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                color: AhpsicoColors.green,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.message,
                        color: AhpsicoColors.light80,
                      ),
                      AhpsicoSpacing.horizontalSpaceSmall,
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "ABRIR NO WHATSAPP",
                          style: AhpsicoText.smallStyle.copyWith(
                            color: AhpsicoColors.light80,
                          ),
                        ),
                      ),
                      AhpsicoSpacing.horizontalSpaceSmall,
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              onTap: model.openCreateAssignmentSheet,
              child: Material(
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                color: AhpsicoColors.blue,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.home_work,
                        color: AhpsicoColors.light80,
                      ),
                      AhpsicoSpacing.horizontalSpaceSmall,
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "CRIAR TAREFA",
                          style: AhpsicoText.smallStyle.copyWith(
                            color: AhpsicoColors.light80,
                          ),
                        ),
                      ),
                      AhpsicoSpacing.horizontalSpaceSmall,
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                TextButton(
                  onPressed: () => model.addPhoneToClipboard(patient.phoneNumber),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    )),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Telefone:",
                        style: AhpsicoText.title3Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.horizontalSpaceSmall,
                      Expanded(
                        child: Text(
                          MaskFormatters.phoneMaskFormatter
                              .maskText(patient.phoneNumber.substring(3)),
                          style: AhpsicoText.title3Style.copyWith(
                            color: AhpsicoColors.dark25,
                          ),
                        ),
                      ),
                      const Icon(Icons.copy),
                    ],
                  ),
                ),
                AhpsicoSpacing.verticalSpaceMedium,
                Row(
                  children: [
                    HomeButton(
                      text: "VER SESSÕES",
                      enableFlex: true,
                      color: AhpsicoColors.violet,
                      icon: Icons.groups,
                      onPressed: () => context.push(
                        SessionList.route,
                        extra: SessionList.buildArgs(patient: patient),
                      ),
                    ),
                    AhpsicoSpacing.horizontalSpaceSmall,
                    HomeButton(
                      text: "VER TAREFAS",
                      enableFlex: true,
                      color: AhpsicoColors.green,
                      icon: Icons.home_work,
                      onPressed: () => context.push(
                        AssignmentsList.route,
                        extra: patient,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AhpsicoSpacing.verticalSpaceLarge,
            Text(
              "Sessões agendadas com você",
              style: AhpsicoText.title3Style.copyWith(
                color: AhpsicoColors.dark25,
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
