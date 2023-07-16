import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/components/patient_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail.dart';
import 'package:ahpsico/ui/patient/list/patient_list_model.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/viewmodel_builder.dart';

class PatientList extends StatelessWidget {
  const PatientList({
    super.key,
    required this.selectMode,
  });

  static const route = "/patients";

  final bool selectMode;

  static Map<String, dynamic> buildArgs({bool selectMode = false}) {
    return {"selectMode": selectMode};
  }

  void _listenToEvents(
    BuildContext context,
    PatientListModel model,
    PatientListEvent event,
  ) {
    switch (event) {
      case PatientListEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case PatientListEvent.navigateToLogin:
        context.go(LoginScreen.route);
    }
  }

  String getTitle(PatientListModel model) {
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.light,
      body: ViewModelBuilder(
        provider: patientListModelProvider,
        onEventEmitted: _listenToEvents,
        onCreate: (model) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => model.fetchScreenData(),
          );
        },
        builder: (context, model) {
          if (model.isLoading || model.user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AhpsicoColors.violet,
              ),
            );
          }
          return WillPopScope(
            onWillPop: () async {
              if (selectMode) {
                context.pop(model.selectedPatientIds);
                return false;
              }
              return true;
            },
            child: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      Topbar(
                        title: getTitle(model),
                        onBackPressed: () {
                          if (selectMode) {
                            return context.pop(model.selectedPatientIds);
                          }
                          context.pop();
                        },
                      )
                    ];
                  },
                  body: ListView(
                    children: model.patients.mapToList((patient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PatientCard(
                          patient: patient,
                          onTap: (patient) {
                            if (selectMode) {
                              return model.selectPatient(patient);
                            }
                            context.push(PatientDetail.route, extra: patient);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
