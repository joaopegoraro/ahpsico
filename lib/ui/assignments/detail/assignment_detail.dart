import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/constants/assignment_status.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail_model.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/home_button.dart';
import 'package:ahpsico/ui/session/card/session_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentDetail extends StatelessWidget {
  const AssignmentDetail(
    this._assignment, {
    super.key,
  });

  static const route = "/assignment/detail";

  final Assignment _assignment;

  Assignment _getAssignment(AssignmentDetailModel model) {
    return model.updatedAssignment ?? _assignment;
  }

  void _onEventEmitted(
    BuildContext context,
    AssignmentDetailModel model,
    AssignmentDetailEvent event,
  ) {
    final assignment = _getAssignment(model);
    switch (event) {
      case AssignmentDetailEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case AssignmentDetailEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case AssignmentDetailEvent.navigateToLogin:
        context.go(LoginScreen.route);
      case AssignmentDetailEvent.cancelAssignment:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja cancelar a tarefa?",
          onTapFirstButton: () {
            context.pop();
            model.cancelAssignment(assignment);
          },
          firstButtonText: "Sim, cancelar a tarefa",
          secondButtonText: "Não, fechar",
        );

      case AssignmentDetailEvent.concludeAssignment:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja marcar a tarefa como concluída?",
          onTapFirstButton: () {
            context.pop();
            model.concludeAssignment(assignment);
          },
          firstButtonText: "Sim, marcar como concluída",
          secondButtonText: "Não, fechar",
        );
      case AssignmentDetailEvent.deleteAssignment:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja deletar a tarefa?",
          onTapFirstButton: () {
            context.pop();
            model.deleteAssignment(assignment).then((updatedAssignment) {
              context.pop(true);
            });
          },
          firstButtonText: "Sim, deletar a tarefa",
          secondButtonText: "Não, fechar",
        );
    }
  }

  String getAssignmentStatus(Assignment assignment) =>
      switch (assignment.status) {
        AssignmentStatus.done => "Concluída",
        AssignmentStatus.missed => "Não concluída",
        AssignmentStatus.pending => "Pendente",
      };

  Color getStatusColor(Assignment assignment) => switch (assignment.status) {
        AssignmentStatus.done => AhpsicoColors.green,
        AssignmentStatus.missed => AhpsicoColors.red,
        AssignmentStatus.pending => AhpsicoColors.yellow,
      };

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: assignmentDetailModelProvider,
      onEventEmitted: _onEventEmitted,
      onCreate: (model) {
        model.fetchScreenData();
      },
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      topbarBuilder: (context, model) {
        return Topbar(
            title: "Tarefa",
            onBackPressed: () {
              if (model.updatedAssignment != null) {
                context.go(LoginScreen.route);
              } else {
                context.pop();
              }
            });
      },
      bodyBuilder: (context, model) {
        final assignment = _getAssignment(model);
        return WillPopScope(
          onWillPop: () async {
            if (model.updatedAssignment != null) {
              context.go(LoginScreen.route);
              return false;
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              assignment.title,
                              style: AhpsicoText.title2Style.copyWith(
                                color: AhpsicoColors.dark25,
                              ),
                            ),
                          ),
                          Chip(
                            backgroundColor: getStatusColor(assignment),
                            label: Text(
                              getAssignmentStatus(assignment),
                              style: AhpsicoText.regular1Style
                                  .copyWith(color: AhpsicoColors.light80),
                            ),
                          ),
                        ],
                      ),
                      AhpsicoSpacing.verticalSpaceRegular,
                      Text(
                        "Descrição",
                        style: AhpsicoText.title3Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceRegular,
                      Text(
                        assignment.description,
                        style: AhpsicoText.regular2Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceLarge,
                      Text(
                        "Sessão de entrega",
                        style: AhpsicoText.title3Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceRegular,
                      SessionCard(
                        session: assignment.session,
                        onTap: (session) => context.push(
                          SessionDetail.route,
                          extra: session,
                        ),
                        isUserDoctor: model.user!.role.isDoctor,
                      ),
                      const Expanded(
                          child: AhpsicoSpacing.verticalSpaceMassive),
                      Row(
                        children: [
                          HomeButton(
                            text: "CONCLUIR\nTAREFA",
                            enableFlex: true,
                            onPressed: model.emitConcludeAssignmentEvent,
                            color: AhpsicoColors.green,
                            icon: Icons.check,
                          ),
                          AhpsicoSpacing.horizontalSpaceSmall,
                          HomeButton(
                            text: "CANCELAR\nTAREFA",
                            enableFlex: true,
                            onPressed: model.emitCancelAssignmentEvent,
                            color: model.user!.role.isDoctor
                                ? AhpsicoColors.yellow
                                : AhpsicoColors.red,
                            icon: Icons.cancel,
                          ),
                        ],
                      ),
                      if (model.user!.role.isDoctor) ...[
                        AhpsicoSpacing.verticalSpaceSmall,
                        HomeButton(
                          text: "EXCLUIR TAREFA",
                          onPressed: model.emitDeleteAssignmentEvent,
                          color: AhpsicoColors.red,
                          icon: Icons.delete,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
