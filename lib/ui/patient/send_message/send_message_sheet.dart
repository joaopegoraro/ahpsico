import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/send_message/send_message_dialog.dart';
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
      case SendMessageEvent.openConfirmationDialog:
        showDialog(
          context: context,
          builder: (context) => SendMessageDialog(
            onConfirm: () => model.sendMessage(widget.patientIds),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ViewModelBuilder(
        provider: sendMessageModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Digite a mensagem que será enviada para os pacientes selecionados",
                  style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.dark75),
                ),
                AhpsicoSpacing.verticalSpaceRegular,
                AhpsicoInputField(
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
            ),
          );
        },
      ),
    );
  }
}
