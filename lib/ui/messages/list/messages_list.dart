import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/messages/list/messages_list_model.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/messages/card/message_card.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key, required this.patient});

  static const route = "/messages";

  final User? patient;

  void _onEventEmitted(
    BuildContext context,
    MessageListModel model,
    MessageListEvent event,
  ) {
    switch (event) {
      case MessageListEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case MessageListEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case MessageListEvent.navigateToLogin:
        context.go(LoginScreen.route);
      case MessageListEvent.openDeleteConfirmationDialog:
        AhpsicoDialog.show(
            context: context,
            content:
                "Tem certeza que deseja deletar as mensagens selecionadas?",
            onTapFirstButton: () {
              context.pop();
              model.deleteSelectedMessages();
            },
            firstButtonText: "Sim, tenho certeza",
            secondButtonText: "Não, cancelar");
    }
  }

  String _getTitle(MessageListModel model) {
    if (model.isSelectModeOn) {
      final lenght = model.selectedMessagesIds.length;
      if (lenght == 0) return "Nenhum selecionado";
      if (lenght == model.messages.length) return "Todos selecionados";
      return "$lenght ${lenght > 1 ? "selecionados" : "selecionado"}";
    }
    return "Mensagens enviadas";
  }

  bool _shouldPop(MessageListModel model) {
    if (model.isSelectModeOn) {
      model.clearSelection();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: messageListModelProvider,
      onEventEmitted: _onEventEmitted,
      onWillPop: (model) async => _shouldPop(model),
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData(patientId: patient?.id);
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: _getTitle(model),
          onBackPressed: context.pop,
          actions: [
            if (model.isSelectModeOn)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  onPressed: model.openDeleteConfirmationDialog,
                  color: AhpsicoColors.light80,
                  icon: const Icon(Icons.delete),
                ),
              ),
          ],
        );
      },
      bodyBuilder: (context, model) {
        if (model.messages.isEmpty) {
          return Center(
            child: Text(
              "Nenhuma mensagem encontrada",
              style: AhpsicoText.title3Style.copyWith(
                color: AhpsicoColors.dark75,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: model.messages.length,
          itemBuilder: (context, index) {
            final message = model.messages[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MessageCard(
                message: message,
                isUserDoctor: true,
                selectModeOn: model.isSelectModeOn,
                showTitle: patient == null,
                isSelected: model.selectedMessagesIds.contains(message.id),
                onLongPress: model.selectMessage,
                onTap: model.isSelectModeOn ? model.selectMessage : null,
              ),
            );
          },
        );
      },
    );
  }
}
