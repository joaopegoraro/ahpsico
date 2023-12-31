import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/home/doctor_home.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/send_message/send_message_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class SendMessageSheet extends StatefulWidget {
  const SendMessageSheet({super.key, required this.patientIds});

  final List<String> patientIds;

  @override
  State<SendMessageSheet> createState() => _SendMessageSheetState();
}

class _SendMessageSheetState extends State<SendMessageSheet> {
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
    SendMessageModel model,
    SendMessageEvent event,
  ) {
    switch (event) {
      case SendMessageEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case SendMessageEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case SendMessageEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case SendMessageEvent.closeSheet:
        context.pop();
      case SendMessageEvent.navigateToHomeScreen:
        context.go(DoctorHome.route);
      case SendMessageEvent.openConfirmationDialog:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja enviar essa mensagem para os pacientes selecionados?",
          firstButtonText: "Sim, tenho certeza",
          secondButtonText: "Não, cancelar",
          onTapFirstButton: () {
            context.pop();
            model.sendMessage(widget.patientIds);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AhpsicoSheet(
      content: ViewModelBuilder(
        provider: sendMessageModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return Column(
            children: [
              Text(
                "Digite a mensagem que será enviada para os pacientes selecionados",
                style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.dark75),
              ),
              AhpsicoSpacing.verticalSpaceRegular,
              AhpsicoInputField(
                minLines: 3,
                maxLenght: 200,
                textAlign: TextAlign.start,
                onChanged: model.updateMessage,
                hint: "Digite a mensagem",
                controller: _controller,
              ),
              AhpsicoSpacing.verticalSpaceRegular,
              AhpsicoButton(
                "ENVIAR MENSAGEM",
                width: double.infinity,
                onPressed: model.openConfirmationDialog,
                isLoading: model.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
