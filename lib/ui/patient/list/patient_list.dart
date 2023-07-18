import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/patient_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail.dart';
import 'package:ahpsico/ui/patient/list/patient_list_model.dart';
import 'package:ahpsico/ui/patient/list/patient_search_delegate.dart';
import 'package:ahpsico/ui/patient/send_message/send_message_sheet.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void _onEventEmmited(
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
        AhpsicoSheet.show(
          context: context,
          builder: (context) => SendMessageSheet(
            patientIds: model.selectedPatientIds,
          ),
        );
      case PatientListEvent.openSearchBar:
        showSearch(
          context: context,
          delegate: PatientSearchDelegate(model.patients),
        ).then((patient) {
          if (patient != null) {
            context.push(PatientDetail.route, extra: patient);
          }
        });
    }
  }

  String _getTitle(PatientListModel model) {
    if (model.isSelectModeOn) {
      final lenght = model.selectedPatientIds.length;
      if (lenght == 0) return "Nenhum selecionado";
      if (lenght == model.patients.length) return "Todos selecionados";
      return "$lenght ${lenght > 1 ? "selecionados" : "selecionado"}";
    }
    return "Seus pacientes";
  }

  bool _shouldPop(PatientListModel model) {
    if (selectModeByDefault || allSelectedByDefault) {
      final isEmpty = model.selectedPatientIds.isEmpty;
      model.clearSelection();
      return isEmpty;
    }
    if (model.isSelectModeOn) {
      model.clearSelection();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: patientListModelProvider,
      onEventEmitted: _onEventEmmited,
      onWillPop: (model) async => _shouldPop(model),
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        if (selectModeByDefault) {
          model.enableSelectModeByDefault();
        }
        model.fetchScreenData().whenComplete(() {
          if (allSelectedByDefault) {
            model.selectAllPatients();
          }
        });
      },
      fabBuilder: (context, model) {
        if (model.isLoading || !model.isSelectModeOn) return null;
        return Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
            backgroundColor: AhpsicoColors.violet,
            foregroundColor: AhpsicoColors.light80,
            onPressed: model.openSendMessageSheet,
            icon: const Icon(Icons.send),
            label: const Text("ENVIAR MENSAGEM"),
          ),
        );
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: _getTitle(model),
          onBackPressed: () {
            if (_shouldPop(model)) context.pop();
          },
          actions: [
            model.isSelectModeOn
                ? PopupMenuButton(
                    child: const Icon(
                      Icons.more_vert,
                      color: AhpsicoColors.light80,
                    ),
                    itemBuilder: (context) => [
                      if (model.areAllPatientsSelected)
                        PopupMenuItem(
                          onTap: model.clearSelection,
                          child: const Text('Limpar seleção'),
                        ),
                      if (!model.areAllPatientsSelected)
                        PopupMenuItem(
                          onTap: model.selectAllPatients,
                          child: const Text('Selecionar todos'),
                        ),
                    ],
                  )
                : IconButton(
                    onPressed: model.openSearchBar,
                    color: AhpsicoColors.light80,
                    icon: const Icon(Icons.search),
                  ),
          ],
        );
      },
      bodyBuilder: (context, model) {
        return ListView(
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
        );
      },
    );
  }
}
