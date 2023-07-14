import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/doctor/doctor_home_model.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab.dart';
import 'package:ahpsico/ui/doctor/widgets/doctor_fab_action.dart';
import 'package:ahpsico/ui/doctor/widgets/home_button.dart';
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
      appBar: const AhpsicoTopbar(title: "Olá, Andréa"),
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Hoje você possui",
                    style: AhpsicoText.regular3Style.copyWith(
                      color: AhpsicoColors.light20,
                    ),
                  ),
                  AhpsicoSpacing.verticalSpaceSmall,
                  Text(
                    "3 sessões",
                    style: AhpsicoText.title1Style.copyWith(
                      color: AhpsicoColors.dark75,
                    ),
                  ),
                  AhpsicoSpacing.verticalSpaceMedium,
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
                          "Sessões de hoje",
                          style: AhpsicoText.title3Style.copyWith(
                            color: AhpsicoColors.dark,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
