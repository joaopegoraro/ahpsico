import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum AssignmentDetailEvent {
  concludeAssignment,
  cancelAssignment,
  deleteAssignment,
  showSnackbarError,
  showSnackbarMessage,
  navigateToLogin,
}

final assignmentDetailModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final assignmentRepository = ref.watch(assignmentRepositoryProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return AssignmentDetailModel(
    authService,
    userRepository,
    preferencesRepository,
    assignmentRepository,
  );
});

class AssignmentDetailModel extends BaseViewModel<AssignmentDetailEvent> {
  AssignmentDetailModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
    this._assignmentRepository,
  ) : super(
          errorEvent: AssignmentDetailEvent.showSnackbarError,
          messageEvent: AssignmentDetailEvent.showSnackbarMessage,
          navigateToLoginEvent: AssignmentDetailEvent.navigateToLogin,
        );

  /* Services */

  final AssignmentRepository _assignmentRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Method */

  void emitCancelAssignmentEvent() {
    emitEvent(AssignmentDetailEvent.cancelAssignment);
  }

  void emitConcludeAssignmentEvent() {
    emitEvent(AssignmentDetailEvent.concludeAssignment);
  }

  void emitDeleteAssignmentEvent() {
    emitEvent(AssignmentDetailEvent.deleteAssignment);
  }

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    updateUi(() => _isLoading = false);
  }

  Future<Assignment?> concludeAssignment(Assignment assignment) async {
    updateUi(() => _isLoading = true);

    final (newAssignment, err) = await _assignmentRepository.update(
      assignment.copyWith(status: AssignmentStatus.done),
    );

    if (err != null) {
      await handleDefaultErrors(
        err,
        defaultErrorMessage: "Ocorreu um erro desconhecido ao tentar concluir a tarefa."
            " Tente novamente mais tarde ou entre em contato com o suporte",
      );
      updateUi(() => _isLoading = false);
      return null;
    }

    updateUi(() => _isLoading = false);
    showSnackbar(
      "Tarefa concluída com sucesso!",
      AssignmentDetailEvent.showSnackbarMessage,
    );

    return newAssignment;
  }

  Future<Assignment?> cancelAssignment(Assignment assignment) async {
    updateUi(() => _isLoading = true);

    final (newAssignment, err) = await _assignmentRepository.update(
      assignment.copyWith(status: AssignmentStatus.missed),
    );
    if (err != null) {
      await handleDefaultErrors(
        err,
        defaultErrorMessage: "Ocorreu um erro desconhecido ao tentar cancelar a tarefa."
            " Tente novamente mais tarde ou entre em contato com o suporte",
      );
      updateUi(() => _isLoading = false);
      return null;
    }

    updateUi(() => _isLoading = false);
    showSnackbar(
      "Tarefa cancelada com sucesso!",
      AssignmentDetailEvent.showSnackbarMessage,
    );

    return newAssignment;
  }

  Future<void> deleteAssignment(Assignment assignment) async {
    updateUi(() => _isLoading = true);

    final err = await _assignmentRepository.delete(assignment.id);
    if (err != null) {
      await handleDefaultErrors(
        err,
        defaultErrorMessage: "Ocorreu um erro desconhecido ao tentar deletar a tarefa."
            " Tente novamente mais tarde ou entre em contato com o suporte",
      );
      return updateUi(() => _isLoading = false);
    }

    updateUi(() => _isLoading = false);
    showSnackbar(
      "Tarefa deletada com sucesso!",
      AssignmentDetailEvent.showSnackbarMessage,
    );
  }
}
