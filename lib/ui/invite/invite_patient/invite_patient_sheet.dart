import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/phone_input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/invite/invite_patient/invite_patient_dialog.dart';
import 'package:ahpsico/ui/invite/invite_patient/invite_patient_model.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class InvitePatientSheet extends StatefulWidget {
  const InvitePatientSheet({super.key});

  @override
  State<InvitePatientSheet> createState() => _InvitePatientSheetState();
}

class _InvitePatientSheetState extends State<InvitePatientSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listenToEvents(
    BuildContext context,
    InvitePatientModel model,
    InvitePatientEvent event,
  ) {
    switch (event) {
      case InvitePatientEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case InvitePatientEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case InvitePatientEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case InvitePatientEvent.closeSheet:
        context.pop();
      case InvitePatientEvent.openPatientNotRegisteredDialog:
        showDialog(
          context: context,
          builder: (context) => const InvitePatientDialog(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: ViewModelBuilder(
        provider: invitePatientModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Digite o número de telefone do paciente",
                  style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.dark75),
                ),
                AhpsicoSpacing.verticalSpaceRegular,
                PhoneInputField(
                  onChanged: model.updatePhone,
                  textAlign: TextAlign.start,
                  controller: _controller,
                  isPhoneValid: model.isPhoneValid,
                ),
                AhpsicoSpacing.verticalSpaceRegular,
                AhpsicoButton(
                  "ENVIAR CONVITE PARA TERAPIA",
                  width: double.infinity,
                  onPressed: model.invitePatient,
                  isLoading: model.isLoading,
                ),
                AhpsicoSpacing.verticalSpaceLarge,
              ],
            ),
          );
        },
      ),
    );
  }
}
