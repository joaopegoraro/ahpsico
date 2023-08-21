import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail.dart';
import 'package:ahpsico/ui/assignments/list/assignments_list_model.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/assignments/card/assignment_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentsList extends StatelessWidget {
  const AssignmentsList({
    super.key,
    required this.patient,
  });

  static const route = "/assignments";

  final User? patient;

  void _onEventEmitted(
    BuildContext context,
    AssignmentListModel model,
    AssignmentListEvent event,
  ) {
    switch (event) {
      case AssignmentListEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case AssignmentListEvent.navigateToLogin:
        context.go(LoginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: assignmentListModelProvider,
      onEventEmitted: _onEventEmitted,
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData(patientUuid: patient?.uuid);
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Tarefas",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        if (model.assignments.isEmpty) {
          return Center(
            child: Text(
              "Nenhuma tarefa encontrada",
              style: AhpsicoText.title3Style.copyWith(
                color: AhpsicoColors.dark75,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: model.assignments.length,
          itemBuilder: (context, index) {
            final assignment = model.assignments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AssignmentCard(
                assignment: assignment,
                isUserDoctor: patient != null,
                onTap: (assignment) {
                  context.push(AssignmentDetail.route, extra: assignment).then((shouldRefresh) {
                    if (shouldRefresh == true) {
                      model.fetchScreenData(patientUuid: patient?.uuid);
                    }
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
