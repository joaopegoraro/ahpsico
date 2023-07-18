import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail.dart';
import 'package:ahpsico/ui/assignments/list/assignments_list_model.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/assignment_card.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentsList extends StatelessWidget {
  const AssignmentsList({
    super.key,
    required this.patient,
  });

  static const route = "/assignments";

  final Patient? patient;

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
        model.fetchScreenData();
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Tarefas",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        return ListView(
          children: model.assignments.mapToList((assignment) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AssignmentCard(
                assignment: assignment,
                isUserDoctor: patient != null,
                onTap: (assignment) {
                  context.push(AssignmentDetail.route, extra: assignment);
                },
              ),
            );
          }),
        );
      },
    );
  }
}
