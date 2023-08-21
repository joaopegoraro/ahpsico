import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/booking/booking_screen.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/doctor/card/doctor_card.dart';
import 'package:ahpsico/ui/doctor/list/doctor_list_model.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class DoctorList extends StatelessWidget {
  const DoctorList({super.key});

  static const route = "/doctors";

  void _onEventEmitted(
    BuildContext context,
    DoctorListModel model,
    DoctorListEvent event,
  ) {
    switch (event) {
      case DoctorListEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case DoctorListEvent.navigateToLogin:
        context.go(LoginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: doctorListModelProvider,
      onEventEmitted: _onEventEmitted,
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData();
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Psicólogos",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        if (model.doctors.isEmpty) {
          return Center(
            child: Text(
              "Nenhum psicólogo encontrado",
              style: AhpsicoText.title3Style.copyWith(
                color: AhpsicoColors.dark75,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: model.doctors.length,
          itemBuilder: (context, index) {
            final doctor = model.doctors[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DoctorCard(
                doctor: doctor,
                onTap: (doctor) {
                  context
                      .push(
                        BookingScreen.route,
                        extra: BookingScreen.buildArgs(doctor: doctor),
                      )
                      .then((_) => context.pop());
                },
              ),
            );
          },
        );
      },
    );
  }
}
