import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/ui/advices/advices_screen.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/session_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/doctor_home_model.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab_action.dart';
import 'package:ahpsico/ui/doctor/widgets/home_button.dart';
import 'package:ahpsico/ui/doctor/widgets/home_topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/patient_home.dart';
import 'package:ahpsico/ui/schedule/schedule_screen.dart';
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
      case DoctorHomeEvent.navigateToDoctorProfileScreen:
        context.push(DoctorHome.route);
      case DoctorHomeEvent.navigateToPatientScreen:
        context.push(PatientHome.route);
      case DoctorHomeEvent.navigateToSentAdvicesScreen:
        context.push(AdvicesScreen.route);
      case DoctorHomeEvent.navigateToScheduleScreen:
        context.push(ScheduleScreen.route);
      case DoctorHomeEvent.openInvitePatientBottomSheet:
      case DoctorHomeEvent.openSendAdviceBottomSheet:
      case DoctorHomeEvent.openSendAdviceToAllBottomSheet:
      case DoctorHomeEvent.openLogoutConfirmationDialog:
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      provider: doctorHomeModelProvider,
      onEventEmitted: _listenToEvents,
      onCreate: (model) => model.fetchScreenData(),
      builder: (context, model) {
        return Scaffold(
            backgroundColor: AhpsicoColors.light,
            floatingActionButton: model.isFetchingScreenData
                ? null
                : DoctorFab(
                    distance: 112,
                    children: [
                      DoctorFabAction(
                        onPressed: () {/* TODO: Abrir bottomsheet de adicionar paciente */},
                        icon: const Icon(Icons.person_add),
                      ),
                      DoctorFabAction(
                        onPressed: () {/* TODO: Abrir bottomsheet de enviar dicas */},
                        icon: const Icon(Icons.tips_and_updates),
                      ),
                      DoctorFabAction(
                        onPressed: () {/* TODO: Abrir bottomsheet de enviar dicas */},
                        icon: const Icon(Icons.outgoing_mail),
                      ),
                    ],
                  ),
            body: Builder(
              builder: (context) {
                if (model.isFetchingScreenData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AhpsicoColors.violet,
                    ),
                  );
                }

                return NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      HomeTopbar(
                        userName: model.user!.firstName,
                        goToProfile: () {
                          // TODO: Open doctor profile screen
                        },
                        logout: () {
                          // TODO: Open logout dialog
                        },
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
                            onPressed: () {/* TODO: Abrir tela de pacientes */},
                          ),
                          AhpsicoSpacing.horizontalSpaceSmall,
                          HomeButton(
                            text: "VER DICAS ENVIADAS",
                            enableFlex: true,
                            color: AhpsicoColors.green,
                            icon: Icons.tips_and_updates,
                            onPressed: () {/* TODO: Abrir tela de dicas enviadas */},
                          ),
                        ],
                      ),
                      AhpsicoSpacing.verticalSpaceMedium,
                      TextButton(
                        onPressed: () {/* TODO: Abrir tela de agenda */},
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
                        return SessionCard(session: session);
                      }),
                      AhpsicoSpacing.verticalSpaceMedium,
                    ].map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: item,
                      );
                    }).toList(),
                  ),
                );
              },
            ));
      },
    );
  }
}

final sessions = <Session>[
  Session(
    id: 0,
    doctor: const Doctor(
      uuid: "",
      name: "Andréa Hahmeyer Pegoraro",
      phoneNumber: "",
      description: "",
      crp: "",
      pixKey: "",
      paymentDetails: "",
    ),
    patient: const Patient(
      uuid: "",
      name: "Luiza Mel",
      phoneNumber: "(49) 98247-7126",
    ),
    groupId: 0,
    groupIndex: 2,
    status: SessionStatus.concluded,
    type: SessionType.individual,
    date: DateTime.now(),
  ),
  Session(
    id: 0,
    doctor: const Doctor(
      uuid: "",
      name: "Andréa Hahmeyer Pegoraro",
      phoneNumber: "",
      description: "",
      crp: "",
      pixKey: "",
      paymentDetails: "",
    ),
    patient: const Patient(
      uuid: "",
      name: "Júlia Ferreira",
      phoneNumber: "(49) 98876-5587",
    ),
    groupId: 0,
    groupIndex: 2,
    status: SessionStatus.confirmed,
    type: SessionType.monthly,
    date: DateTime.now(),
  ),
  Session(
    id: 1,
    doctor: const Doctor(
      uuid: "",
      name: "Andréa Hahmeyer Pegoraro",
      phoneNumber: "",
      description: "",
      crp: "",
      pixKey: "",
      paymentDetails: "",
    ),
    patient: const Patient(
      uuid: "",
      name: "Larrisa Gomes",
      phoneNumber: "(47) 99521-2197",
    ),
    groupId: 0,
    groupIndex: 0,
    status: SessionStatus.notConfirmed,
    type: SessionType.individual,
    date: DateTime.now(),
  ),
  Session(
    id: 2,
    doctor: const Doctor(
      uuid: "",
      name: "Andréa Hahmeyer Pegoraro",
      phoneNumber: "",
      description: "",
      crp: "",
      pixKey: "",
      paymentDetails: "",
    ),
    patient: const Patient(
      uuid: "",
      name: "Raul Silva",
      phoneNumber: "(49) 99183-8071",
    ),
    groupId: 0,
    groupIndex: 0,
    status: SessionStatus.canceled,
    type: SessionType.individual,
    date: DateTime.now(),
  ),
];
