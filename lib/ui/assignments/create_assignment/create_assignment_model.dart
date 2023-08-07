import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
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
    try {
      await getUserData();
      final doctor = await userRepository.get(user!.uuid);
      final assignment = Assignment(
        id: 0,
        title: title,
        description: description,
        doctor: doctor,
        patientId: patient.uuid,
        status: AssignmentStatus.pending,
        deliverySession: session,
      );
      await _assignmentRepository.create(assignment);
      showSnackbar(
        "Tarefa criada com sucesso!",
        CreateAssignmentEvent.showSnackbarMessage,
      );
      emitEvent(CreateAssignmentEvent.closeSheet);
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    updateUi(() => _isLoading = false);
  }
}
