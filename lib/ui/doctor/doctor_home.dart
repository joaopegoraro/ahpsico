import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/doctor/doctor_home_model.dart';
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
      backgroundColor: AhpsicoColors.light,
      body: ViewModelBuilder(
        provider: doctorHomeModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HomeButton(
                    text: "VER PACIENTES",
                    color: AhpsicoColors.violet,
                    icon: Icons.groups,
                    onPressed: () {},
                  ),
                  AhpsicoSpacing.verticalSpaceSmall,
                  HomeButton(
                    text: "VER DICAS ENVIADAS",
                    color: AhpsicoColors.green,
                    icon: Icons.tips_and_updates,
                    onPressed: () {},
                  ),
                  AhpsicoSpacing.verticalSpaceMedium,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sessões de hoje",
                      style: AhpsicoText.title3Style.copyWith(
                        color: AhpsicoColors.dark,
                      ),
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
