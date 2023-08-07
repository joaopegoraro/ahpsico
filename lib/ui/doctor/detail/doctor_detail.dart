import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/bottomsheet.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/doctor/detail/doctor_detail_model.dart';
import 'package:ahpsico/ui/doctor/edit_doctor/edit_doctor_sheet.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetail extends StatelessWidget {
  const DoctorDetail(
    this.doctor, {
    super.key,
  });

  static const route = "/doctor/detail";

  final User? doctor;

  void _onEventEmitted(
    BuildContext context,
    DoctorDetailModel model,
    DoctorDetailEvent event,
  ) {
    switch (event) {
      case DoctorDetailEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case DoctorDetailEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case DoctorDetailEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case DoctorDetailEvent.openEditProfileSheet:
        AhpsicoSheet.show(
          context: context,
          builder: (context) {
            return EditDoctorSheet(doctor: model.doctor!);
          },
        ).then((shouldRefresh) {
          if (shouldRefresh == true) {
            model.fetchScreenData(doctor: doctor);
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: doctorDetailModelProvider,
      onEventEmitted: _onEventEmitted,
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null || model.doctor == null;
      },
      onCreate: (model) {
        model.fetchScreenData(doctor: doctor);
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: doctor == null ? "Perfil" : "Psicólogo",
          onBackPressed: context.pop,
          actions: [
            if (doctor == null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: model.openEditProfileSheet,
              ),
          ],
        );
      },
      fabBuilder: (context, value) {
        if (doctor == null) return null;
        return FloatingActionButton.extended(
          backgroundColor: AhpsicoColors.green,
          label: Text(
            "FALAR PELO WHATSAPP",
            style: AhpsicoText.smallStyle.copyWith(
              color: AhpsicoColors.light80,
            ),
          ),
          onPressed: () {
            launchUrl(Uri.parse("https://wa.me/${doctor!.phoneNumber}"));
          },
          icon: const Icon(
            Icons.message,
            color: AhpsicoColors.light80,
          ),
        );
      },
      bodyBuilder: (context, model) {
        return ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.doctor!.name,
                  style: AhpsicoText.title2Style.copyWith(
                    color: AhpsicoColors.dark25,
                  ),
                ),
                AhpsicoSpacing.verticalSpaceRegular,
                if (model.doctor!.description.isNotEmpty) ...[
                  Text(
                    model.doctor!.description,
                    style: AhpsicoText.regular1Style.copyWith(
                      color: AhpsicoColors.dark25,
                    ),
                  ),
                  AhpsicoSpacing.verticalSpaceRegular,
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CRP:",
                      style: AhpsicoText.regular1Style.copyWith(
                        color: AhpsicoColors.dark25,
                      ),
                    ),
                    AhpsicoSpacing.horizontalSpaceSmall,
                    Expanded(
                      child: Text(
                        model.doctor!.crp.isEmpty ? "Não informado" : model.doctor!.crp,
                        style: AhpsicoText.regular1Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                    ),
                  ],
                ),
                AhpsicoSpacing.verticalSpaceMedium,
                Text(
                  "Telefone",
                  style: AhpsicoText.title3Style.copyWith(
                    color: AhpsicoColors.dark25,
                  ),
                ),
                AhpsicoSpacing.verticalSpaceSmall,
                TextButton(
                  onPressed: () => model.addPhoneToClipboard(model.doctor!.phoneNumber),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    )),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          MaskFormatters.phoneMaskFormatter.maskText(model.doctor!.phoneNumber),
                          style: AhpsicoText.title3Style.copyWith(
                            color: AhpsicoColors.dark25,
                          ),
                        ),
                      ),
                      const Icon(Icons.copy),
                    ],
                  ),
                ),
                AhpsicoSpacing.verticalSpaceMedium,
                Text(
                  "Dados de pagamento",
                  style: AhpsicoText.title3Style.copyWith(
                    color: AhpsicoColors.dark25,
                  ),
                ),
                AhpsicoSpacing.verticalSpaceSmall,
                TextButton(
                  onPressed: model.doctor!.pixKey.isEmpty
                      ? null
                      : () => model.addPixKeyToClipboard(model.doctor!.pixKey),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    )),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chave PIX:",
                        style: AhpsicoText.regular2Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceSmall,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              model.doctor!.pixKey.isEmpty ? "Não informado" : model.doctor!.pixKey,
                              style: AhpsicoText.regular1Style.copyWith(
                                color: AhpsicoColors.dark25,
                              ),
                            ),
                          ),
                          if (model.doctor!.pixKey.isNotEmpty) const Icon(Icons.copy),
                        ],
                      ),
                    ],
                  ),
                ),
                AhpsicoSpacing.verticalSpaceSmall,
                TextButton(
                  onPressed: model.doctor!.paymentDetails.isEmpty
                      ? null
                      : () => model.addPaymentDetailsToClipboard(model.doctor!.paymentDetails),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    )),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dados bancários:",
                        style: AhpsicoText.regular2Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceSmall,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              model.doctor!.paymentDetails.isEmpty
                                  ? "Não informado"
                                  : model.doctor!.paymentDetails,
                              style: AhpsicoText.regular1Style.copyWith(
                                color: AhpsicoColors.dark25,
                              ),
                            ),
                          ),
                          if (model.doctor!.paymentDetails.isNotEmpty) const Icon(Icons.copy),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ].mapToList((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: item,
            );
          }),
        );
      },
    );
  }
}
