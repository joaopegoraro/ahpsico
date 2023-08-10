import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
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
  const AssignmentDetail({
    super.key,
    required this.assignment,
  });

  static const route = "/assignment/detail";

  final Assignment assignment;

  void _onEventEmitted(
    BuildContext context,
    AssignmentDetailModel model,
    AssignmentDetailEvent event,
  ) {
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
            model.cancelAssignment(assignment).then((updatedAssignment) {
              context.replace(AssignmentDetail.route, extra: updatedAssignment);
            });
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
            model.concludeAssignment(assignment).then((updatedAssignment) {
              context.replace(AssignmentDetail.route, extra: updatedAssignment);
            });
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

  String get assignmentStatus => switch (assignment.status) {
        AssignmentStatus.done => "Concluída",
        AssignmentStatus.missed => "Não concluída",
        AssignmentStatus.pending => "Pendente",
      };

  Color get statusColor => switch (assignment.status) {
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
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            color: statusColor,
                          ),
                          child: Text(
                            assignmentStatus,
                            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.light80),
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
                      session: assignment.deliverySession,
                      onTap: (session) => context.push(
                        SessionDetail.route,
                        extra: session,
                      ),
                      isUserDoctor: model.user!.role.isDoctor,
                    ),
                    const Expanded(child: AhpsicoSpacing.verticalSpaceMassive),
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
                          color: AhpsicoColors.yellow,
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
        );
      },
    );
  }
}
