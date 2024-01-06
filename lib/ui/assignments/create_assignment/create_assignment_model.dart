import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/constants/assignment_status.dart';
import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum CreateAssignmentEvent {
  closeSheet,
  showSnackbarError,
  showSnackbarMessage,
  navigateToLoginScreen,
}

final createAssignmentModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final assignmentRepository = ref.watch(assignmentRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return CreateAssignmentModel(
    authService,
    userRepository,
    preferencesRepository,
    assignmentRepository,
  );
});

class CreateAssignmentModel extends BaseViewModel<CreateAssignmentEvent> {
  CreateAssignmentModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._assignmentRepository,
  ) : super(
          errorEvent: CreateAssignmentEvent.showSnackbarError,
          navigateToLoginEvent: CreateAssignmentEvent.navigateToLoginScreen,
        );

  /* Services */

  final AssignmentRepository _assignmentRepository;

  /* Fields */

  String _title = "";
  String get title => _title;

  String _description = "";
  String get description => _description;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Methods */

  void updateTitle(String title) {
    _title = title;
  }

  void updateDescription(String description) {
    _description = description;
  }

  /* Calls */

  Future<void> createAssignment({
    required User patient,
    required Session? session,
  }) async {
    if (session == null) {
      return showSnackbar(
        "Você precisa escolher uma sessão de entrega da tarefa",
        CreateAssignmentEvent.showSnackbarError,
      );
    }

    if (title.isEmpty) {
      return showSnackbar(
        "O campo de título não pode ficar vazio",
        CreateAssignmentEvent.showSnackbarError,
      );
    }

    if (description.isEmpty) {
      return showSnackbar(
        "O campo de descrição não pode ficar vazio",
        CreateAssignmentEvent.showSnackbarError,
      );
    }

    updateUi(() => _isLoading = true);

    await getUserData();
    final assignment = Assignment(
      id: 0,
      title: title,
      description: description,
      userId: patient.id,
      status: AssignmentStatus.pending,
      session: session,
    );

    final (_, err) = await _assignmentRepository.create(assignment);
    if (err != null) {
      updateUi(() => _isLoading = false);
      return await handleDefaultErrors(
        err,
        defaultErrorMessage:
            "Ocorreu um erro desconhecido ao tentar criar a tarefa. "
            "Tente novamente mais tarde ou entre em contato com o suporte",
      );
    }

    showSnackbar(
      "Tarefa criada com sucesso!",
      CreateAssignmentEvent.showSnackbarMessage,
    );
    emitEvent(CreateAssignmentEvent.closeSheet);

    updateUi(() => _isLoading = false);
  }
}
