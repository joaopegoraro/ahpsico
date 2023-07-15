import 'package:ahpsico/ui/advices/advices_screen.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/dialogs/logout_dialog.dart';
import 'package:ahpsico/ui/components/session_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/detail/doctor_detail.dart';
import 'package:ahpsico/ui/doctor/home/doctor_home_model.dart';
import 'package:ahpsico/ui/doctor/invite_patient/invite_patient_sheet.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab_action.dart';
import 'package:ahpsico/ui/components/home_button.dart';
import 'package:ahpsico/ui/components/home_topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/list/patient_list.dart';
import 'package:ahpsico/ui/schedule/schedule_screen.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  static const route = "/doctor/home";

  void _listenToEvents(
    BuildContext context,
    DoctorHomeModel model,
    DoctorHomeEvent event,
  ) {
    switch (event) {
      case DoctorHomeEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case DoctorHomeEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case DoctorHomeEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case DoctorHomeEvent.openInvitePatientBottomSheet:
        showModalBottomSheet(
          context: context,
          builder: (context) => const InvitePatientSheet(),
        );
      case DoctorHomeEvent.openSendAdviceBottomSheet:
      // TODO
      case DoctorHomeEvent.openSendAdviceToAllBottomSheet:
      // TODO
      case DoctorHomeEvent.openLogoutDialog:
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
    return Scaffold(
      backgroundColor: AhpsicoColors.light,
      body: ViewModelBuilder(
        provider: doctorHomeModelProvider,
        onEventEmitted: _listenToEvents,
        onCreate: (model) => model.fetchScreenData(),
        builder: (context, model) {
          if (model.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AhpsicoColors.violet,
              ),
            );
          }
          return Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    HomeTopbar(
                      userName: model.user!.firstName,
                      goToProfile: () => context.push(DoctorDetail.route),
                      logout: model.openLogoutDialog,
                    )
                  ];
                },
                body: ListView(
                  children: [
                    if (model.sessions.isNotEmpty) ...[
                      Text(
                        "Hoje você possui",
                        style: AhpsicoText.regular3Style.copyWith(
                          color: AhpsicoColors.light20,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceSmall,
                      Text(
                        "${model.sessions.length} sessões",
                        style: AhpsicoText.title1Style.copyWith(
                          color: AhpsicoColors.dark75,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceMedium,
                    ],
                    Row(
                      children: [
                        HomeButton(
                          text: "VER PACIENTES",
                          enableFlex: true,
                          color: AhpsicoColors.violet,
                          icon: Icons.groups,
                          onPressed: () => context.push(PatientList.route),
                        ),
                        AhpsicoSpacing.horizontalSpaceSmall,
                        HomeButton(
                          text: "VER DICAS ENVIADAS",
                          enableFlex: true,
                          color: AhpsicoColors.green,
                          icon: Icons.tips_and_updates,
                          onPressed: () => context.push(AdvicesScreen.route),
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
                            "Agenda de hoje",
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
                          "Você não possui nenhuma sessão hoje",
                          style: AhpsicoText.regular2Style.copyWith(
                            color: AhpsicoColors.dark25,
                          ),
                        ),
                      ),
                    ...model.sessions.map((session) {
                      return SessionCard(
                        session: session,
                        onTap: () => context.push(SessionDetail.route, extra: session),
                      );
                    }),
                    AhpsicoSpacing.verticalSpaceMedium,
                  ].map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: item,
                    );
                  }).toList(),
                ),
              ),
              if (model.isLoading)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DoctorFab(
                      distance: 112,
                      children: [
                        DoctorFabAction(
                          onPressed: model.openInvitePatientSheet,
                          icon: const Icon(Icons.person_add),
                        ),
                        DoctorFabAction(
                          onPressed: () {/* TODO: Abrir bottomsheet de enviar dicas */},
                          icon: const Icon(Icons.tips_and_updates),
                        ),
                        DoctorFabAction(
                          onPressed: model.openSendAdviceSheet,
                          icon: const Icon(Icons.outgoing_mail),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
