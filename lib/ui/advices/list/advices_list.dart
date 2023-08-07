import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/advices/list/advices_list_model.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/advices/card/advice_card.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdvicesList extends StatelessWidget {
  const AdvicesList({super.key, required this.patient});

  static const route = "/advices";

  final User? patient;

  void _onEventEmitted(
    BuildContext context,
    AdviceListModel model,
    AdviceListEvent event,
  ) {
    switch (event) {
      case AdviceListEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case AdviceListEvent.navigateToLogin:
        context.go(LoginScreen.route);
      case AdviceListEvent.openDeleteConfirmationDialog:
        AhpsicoDialog.show(
            context: context,
            content: "Tem certeza que deseja deletar as mensagens selecionadas?",
            onTapFirstButton: () {
              context.pop();
              model.deleteSelectedAdvices();
            },
            firstButtonText: "Sim, tenho certeza",
            secondButtonText: "Não, cancelar");
    }
  }

  String _getTitle(AdviceListModel model) {
    if (model.isSelectModeOn) {
      final lenght = model.selectedAdvicesIds.length;
      if (lenght == 0) return "Nenhum selecionado";
      if (lenght == model.advices.length) return "Todos selecionados";
      return "$lenght ${lenght > 1 ? "selecionados" : "selecionado"}";
    }
    return "Mensagens enviadas";
  }

  bool _shouldPop(AdviceListModel model) {
    if (model.isSelectModeOn) {
      model.clearSelection();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: adviceListModelProvider,
      onEventEmitted: _onEventEmitted,
      onWillPop: (model) async => _shouldPop(model),
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData(patientUuid: patient?.uuid);
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: _getTitle(model),
          onBackPressed: context.pop,
          actions: [
            if (model.isSelectModeOn)
              IconButton(
                onPressed: model.openDeleteConfirmationDialog,
                color: AhpsicoColors.light80,
                icon: const Icon(Icons.delete),
              ),
          ],
        );
      },
      bodyBuilder: (context, model) {
        if (model.advices.isEmpty) {
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
          itemCount: model.advices.length,
          itemBuilder: (context, index) {
            final advice = model.advices[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AdviceCard(
                advice: advice,
                isUserDoctor: true,
                selectModeOn: model.isSelectModeOn,
                showTitle: patient == null,
                isSelected: model.selectedAdvicesIds.contains(advice.id),
                onLongPress: model.selectAdvice,
                onTap: model.isSelectModeOn ? model.selectAdvice : null,
              ),
            );
          },
        );
      },
    );
  }
}
