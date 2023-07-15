import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/session_card.dart';
import 'package:ahpsico/ui/doctor/doctor_home_model.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab_action.dart';
import 'package:ahpsico/ui/doctor/widgets/home_button.dart';
import 'package:ahpsico/ui/doctor/widgets/home_topbar.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  static const route = "/doctor/home";

  void _listenToEvents(
    BuildContext context,
    DoctorHomeModel model,
    DoctorHomeEvent event,
  ) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.light,
      floatingActionButton: DoctorFab(
        distance: 112,
        children: [
          DoctorFabAction(
            onPressed: () {/* TODO */},
            icon: const Icon(Icons.person_add),
          ),
          DoctorFabAction(
            onPressed: () {/* TODO */},
            icon: const Icon(Icons.tips_and_updates),
          ),
          DoctorFabAction(
            onPressed: () {/* TODO */},
            icon: const Icon(Icons.outgoing_mail),
          ),
        ],
      ),
      body: ViewModelBuilder(
        provider: doctorHomeModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [const HomeTopbar(userName: "Andréa")];
            },
            body: ListView(
              children: [
                if (testSessions.isNotEmpty) ...[
                  Text(
                    "Hoje você possui",
                    style: AhpsicoText.regular3Style.copyWith(
                      color: AhpsicoColors.light20,
                    ),
                  ),
                  AhpsicoSpacing.verticalSpaceSmall,
                  Text(
                    "${testSessions.length} sessões",
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
                      onPressed: () {/* TODO */},
                    ),
                    AhpsicoSpacing.horizontalSpaceSmall,
                    HomeButton(
                      text: "VER DICAS ENVIADAS",
                      enableFlex: true,
                      color: AhpsicoColors.green,
                      icon: Icons.tips_and_updates,
                      onPressed: () {/* TODO */},
                    ),
                  ],
                ),
                AhpsicoSpacing.verticalSpaceMedium,
                TextButton(
                  onPressed: () {/* TODO */},
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
                if (testSessions.isEmpty)
                  Center(
                    child: Text(
                      "Você não possui nenhuma sessão hoje",
                      style: AhpsicoText.regular2Style.copyWith(
                        color: AhpsicoColors.dark25,
                      ),
                    ),
                  ),
                ...testSessions.map((session) {
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
      ),
    );
  }
}

final List<Session> testSessions = sessions;
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
