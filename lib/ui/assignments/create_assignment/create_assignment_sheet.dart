import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/assignments/create_assignment/create_assignment_model.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/session/card/session_card.dart';
import 'package:ahpsico/ui/session/list/session_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/viewmodel_builder.dart';

class CreateAssignmentSheet extends StatefulWidget {
  const CreateAssignmentSheet({
    super.key,
    required this.patient,
  });

  final User patient;

  @override
  State<CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState extends State<CreateAssignmentSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _session = null;
    super.dispose();
  }

  void _listenToEvents(
    BuildContext context,
    CreateAssignmentModel model,
    CreateAssignmentEvent event,
  ) {
    switch (event) {
      case CreateAssignmentEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case CreateAssignmentEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case CreateAssignmentEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case CreateAssignmentEvent.closeSheet:
        context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AhpsicoSheet(
      content: ViewModelBuilder(
        provider: createAssignmentModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Criar tarefa",
                  style: AhpsicoText.title3Style.copyWith(
                    color: AhpsicoColors.dark75,
                  ),
                ),
              ),
              AhpsicoSpacing.verticalSpaceMedium,
              Text(
                "Título",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              AhpsicoInputField(
                minLines: 1,
                maxLenght: 100,
                enabled: !model.isLoading,
                textAlign: TextAlign.start,
                onChanged: model.updateTitle,
                hint: "Título",
                controller: _titleController,
              ),
              Text(
                "Descrição",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              AhpsicoInputField(
                minLines: 3,
                maxLenght: 200,
                textAlign: TextAlign.start,
                onChanged: model.updateDescription,
                enabled: !model.isLoading,
                hint: "Descrição",
                controller: _descriptionController,
              ),
              Text(
                "Sessão de entrega",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceMedium,
              if (_session == null)
                InkWell(
                  onTap: () {
                    final futureSession = context.push<Session?>(
                      SessionList.route,
                      extra: SessionList.buildArgs(
                        patient: widget.patient,
                        navigateBackOnTap: true,
                      ),
                    );
                    futureSession.then((session) {
                      setState(() {
                        _session = session;
                      });
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AhpsicoColors.light60,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(50),
                    child: Text(
                      "Escolher sessão de entrega",
                      style: AhpsicoText.regular2Style.copyWith(
                        color: AhpsicoColors.violet80,
                      ),
                    ),
                  ),
                ),
              if (_session != null)
                SessionCard(
                  session: _session!,
                  onTap: (session) {
                    final futureSession = context.push<Session?>(
                      SessionList.route,
                      extra: SessionList.buildArgs(
                        patient: widget.patient,
                        navigateBackOnTap: true,
                      ),
                    );
                    futureSession.then((session) {
                      setState(() {
                        _session = session;
                      });
                    });
                  },
                  isUserDoctor: true,
                ),
              AhpsicoSpacing.verticalSpaceLarge,
              AhpsicoButton(
                "CRIAR TAREFA",
                width: double.infinity,
                onPressed: () {
                  model.createAssignment(
                    patient: widget.patient,
                    session: _session,
                  );
                },
                isLoading: model.isLoading,
              ),
              AhpsicoSpacing.verticalSpaceRegular,
            ],
          );
        },
      ),
    );
  }
}
