import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/edit_name/edit_patient_name_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class EditPatientNameSheet extends StatefulWidget {
  const EditPatientNameSheet({super.key, required this.patient});

  final User patient;

  @override
  State<EditPatientNameSheet> createState() => _EditPatientNameSheetState();
}

class _EditPatientNameSheetState extends State<EditPatientNameSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.patient.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listenToEvents(
    BuildContext context,
    EditPatientNameModel model,
    EditPatientNameEvent event,
  ) {
    switch (event) {
      case EditPatientNameEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case EditPatientNameEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case EditPatientNameEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case EditPatientNameEvent.closeSheet:
        context.pop(true);
      case EditPatientNameEvent.closeSheetWithoutRefreshing:
        context.pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AhpsicoSheet(
      content: ViewModelBuilder(
        provider: editPatientNameModelProvider,
        onCreate: (model) => model.updateName(widget.patient.name),
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return Column(
            children: [
              Text(
                "Digite o novo nome da sua conta",
                style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.dark75),
              ),
              AhpsicoSpacing.verticalSpaceRegular,
              AhpsicoInputField(
                maxLenght: 150,
                textAlign: TextAlign.start,
                onChanged: model.updateName,
                hint: "Nome",
                controller: _controller,
              ),
              AhpsicoSpacing.verticalSpaceRegular,
              AhpsicoButton(
                "ALTERAR NOME",
                width: double.infinity,
                onPressed: () => model.confirmUpdateName(patient: widget.patient),
                isLoading: model.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
