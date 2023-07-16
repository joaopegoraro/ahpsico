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
    required this.selectModeByDefault,
    required this.allSelectedByDefault,
  });

  static const route = "/patients";

  final bool selectModeByDefault;
  final bool allSelectedByDefault;

  static Map<String, dynamic> buildArgs({
    bool selectMode = false,
    bool allSelected = false,
  }) {
    return {
      "selectMode": selectMode,
      "allSelected": allSelected,
    };
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
      case PatientListEvent.openSendMessageSheet:
      // TODO
    }
  }

  String getTitle(PatientListModel model) {
    if (model.isSelectModeOn) {
      final lenght = model.selectedPatientIds.length;
      if (lenght == 0) return "Nenhum selecionado";
      if (lenght == model.patients.length) return "Todos selecionados";
      return "$lenght ${lenght > 1 ? "selecionados" : "selecionado"}";
    }
    return "Seus pacientes";
  }

  bool shouldPop(PatientListModel model) {
    if (selectModeByDefault || allSelectedByDefault) {
      return true;
    }
    if (model.isSelectModeOn) {
      model.clearSelection();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.light,
      body: ViewModelBuilder(
        provider: patientListModelProvider,
        onEventEmitted: _listenToEvents,
        onCreate: (model) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (selectModeByDefault) {
              model.enableSelectModeByDefault();
            }
            model.fetchScreenData().whenComplete(() {
              if (allSelectedByDefault) {
                model.selectAllPatients();
              }
            });
          });
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
            onWillPop: () async => shouldPop(model),
            child: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      Topbar(
                        title: getTitle(model),
                        onBackPressed: () {
                          if (shouldPop(model)) context.pop();
                        },
                        actions: [
                          if (model.isSelectModeOn)
                            IconButton(
                              onPressed: () {
                                if (model.areAllPatientsSelected) {
                                  return model.clearSelection();
                                }
                                model.selectAllPatients();
                              },
                              icon: Icon(model.areAllPatientsSelected ? Icons.inbox : Icons.all_inbox),
                            ),
                        ],
                      )
                    ];
                  },
                  body: ListView(
                    children: model.patients.mapToList((patient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PatientCard(
                          patient: patient,
                          isSelected: model.selectedPatientIds.contains(patient.uuid),
                          showSelected: selectModeByDefault || allSelectedByDefault || model.isSelectModeOn,
                          onLongPress: model.selectPatient,
                          onTap: (patient) {
                            if (model.isSelectModeOn) {
                              return model.selectPatient(patient);
                            }
                            context.push(PatientDetail.route, extra: patient);
                          },
                        ),
                      );
                    }),
                  ),
                ),
                if (!model.isLoading && model.isSelectModeOn)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton.extended(
                        backgroundColor: AhpsicoColors.violet,
                        foregroundColor: AhpsicoColors.light80,
                        onPressed: model.openSendMessageSheet,
                        icon: const Icon(Icons.send),
                        label: const Text("ENVIAR MENSAGEM"),
                      ),
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
