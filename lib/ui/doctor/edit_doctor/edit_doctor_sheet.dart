import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/edit_doctor/edit_doctor_model.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/viewmodel_builder.dart';

class EditDoctorSheet extends StatefulWidget {
  const EditDoctorSheet({
    super.key,
    required this.doctor,
  });

  final User doctor;

  @override
  State<EditDoctorSheet> createState() => _EditDoctorSheetState();
}

class _EditDoctorSheetState extends State<EditDoctorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _crpController;
  late final TextEditingController _pixKeyController;
  late final TextEditingController _paymentDetailsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctor.name);
    _descriptionController = TextEditingController(text: widget.doctor.description);
    _crpController = TextEditingController(text: widget.doctor.crp);
    _pixKeyController = TextEditingController(text: widget.doctor.pixKey);
    _paymentDetailsController = TextEditingController(text: widget.doctor.paymentDetails);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _crpController.dispose();
    _pixKeyController.dispose();
    _paymentDetailsController.dispose();
    super.dispose();
  }

  void _listenToEvents(
    BuildContext context,
    EditDoctorModel model,
    EditDoctorEvent event,
  ) {
    switch (event) {
      case EditDoctorEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case EditDoctorEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case EditDoctorEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case EditDoctorEvent.closeSheet:
        context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AhpsicoSheet(
      content: ViewModelBuilder(
        provider: editDoctorModelProvider,
        onEventEmitted: _listenToEvents,
        onCreate: (model) {
          model.updateName(widget.doctor.name);
          model.updateDescription(widget.doctor.description);
          model.updateCrp(widget.doctor.crp);
          model.updatePixKey(widget.doctor.pixKey);
          model.updatePaymentDetails(widget.doctor.paymentDetails);
        },
        builder: (context, model) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Editar dados do perfil",
                  style: AhpsicoText.title3Style.copyWith(
                    color: AhpsicoColors.dark75,
                  ),
                ),
              ),
              AhpsicoSpacing.verticalSpaceMedium,
              Text(
                "Nome completo",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              AhpsicoInputField(
                minLines: 2,
                maxLenght: 150,
                enabled: !model.isLoading,
                textAlign: TextAlign.start,
                onChanged: model.updateName,
                hint: "Nome completo",
                controller: _nameController,
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
                "CRP",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              AhpsicoInputField(
                maxLenght: 20,
                textAlign: TextAlign.start,
                onChanged: model.updateCrp,
                enabled: !model.isLoading,
                hint: "Registro de CRP",
                controller: _crpController,
              ),
              Text(
                "Chave PIX",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              AhpsicoInputField(
                minLines: 2,
                textAlign: TextAlign.start,
                maxLenght: 512,
                enabled: !model.isLoading,
                onChanged: model.updatePixKey,
                hint: "Chave PIX",
                controller: _pixKeyController,
              ),
              Text(
                "Dados bancários",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.dark75,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              AhpsicoInputField(
                minLines: 2,
                textAlign: TextAlign.start,
                maxLenght: 200,
                enabled: !model.isLoading,
                onChanged: model.updatePaymentDetails,
                hint: "Dados bancários",
                controller: _paymentDetailsController,
              ),
              AhpsicoSpacing.verticalSpaceMedium,
              AhpsicoButton(
                "ATUALIZAR PERFIL",
                width: double.infinity,
                onPressed: model.editProfile,
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
