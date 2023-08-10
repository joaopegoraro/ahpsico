import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/booking/booking_screen.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/home_button.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/doctor/card/doctor_card.dart';
import 'package:ahpsico/ui/doctor/detail/doctor_detail.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/card/patient_card.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail.dart';
import 'package:ahpsico/ui/session/detail/session_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionDetail extends StatelessWidget {
  const SessionDetail(
    this.session, {
    super.key,
  });

  static const route = "/session/detail";

  final Session session;

  void _onEventEmitted(
    BuildContext context,
    SessionDetailModel model,
    SessionDetailEvent event,
  ) {
    switch (event) {
      case SessionDetailEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case SessionDetailEvent.showSnackbarMessage:
      // AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case SessionDetailEvent.navigateToLogin:
        context.go(LoginScreen.route);
      case SessionDetailEvent.cancelSession:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja cancelar a sessão?",
          onTapFirstButton: () {
            context.pop();
            model.cancelSession(session).then((updatedSession) {
              if (updatedSession != null) {
                context.replace(SessionDetail.route, extra: updatedSession);
              }
            });
          },
          firstButtonText: "Sim, cancelar a sessão",
          secondButtonText: "Não, fechar",
        );
      case SessionDetailEvent.concludeSession:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja marcar a sessão como concluída?",
          onTapFirstButton: () {
            context.pop();
            model.concludeSession(session).then((updatedSession) {
              if (updatedSession != null) {
                context.replace(SessionDetail.route, extra: updatedSession);
              }
            });
          },
          firstButtonText: "Sim, marcar como concluída",
          secondButtonText: "Não, fechar",
        );
      case SessionDetailEvent.confirmSession:
        AhpsicoDialog.show(
          context: context,
          content: "Tem certeza que deseja confirmar a sessão?",
          onTapFirstButton: () {
            context.pop();
            model.confirmSession(session).then((updatedSession) {
              if (updatedSession != null) {
                context.replace(SessionDetail.route, extra: updatedSession);
              }
            });
          },
          firstButtonText: "Sim, confirmar a sessão",
          secondButtonText: "Não, fechar",
        );
    }
  }

  String get sessionStatus => switch (session.status) {
        SessionStatus.canceled => "Cancelada",
        SessionStatus.concluded => "Concluída",
        SessionStatus.confirmed => "Confirmada",
        SessionStatus.notConfirmed => "Não confirmada",
      };

  Color get statusColor => switch (session.status) {
        SessionStatus.canceled => AhpsicoColors.red,
        SessionStatus.concluded => AhpsicoColors.violet,
        SessionStatus.confirmed => AhpsicoColors.green,
        SessionStatus.notConfirmed => AhpsicoColors.yellow
      };

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: sessionDetailModelProvider,
      onEventEmitted: _onEventEmitted,
      onCreate: (model) {
        model.fetchScreenData();
      },
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Sessão",
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
                            "${session.readableDate} às ${session.dateTime}",
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
                            sessionStatus,
                            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.light80),
                          ),
                        ),
                      ],
                    ),
                    AhpsicoSpacing.verticalSpaceLarge,
                    Text(
                      model.user!.role.isDoctor ? "Paciente" : "Psicólogo",
                      style: AhpsicoText.title3Style.copyWith(
                        color: AhpsicoColors.dark25,
                      ),
                    ),
                    AhpsicoSpacing.verticalSpaceRegular,
                    model.user!.role.isDoctor
                        ? PatientCard(
                            patient: session.patient,
                            onTap: (patient) => context.push(
                              PatientDetail.route,
                              extra: patient,
                            ),
                          )
                        : DoctorCard(
                            doctor: session.doctor,
                            onTap: (doctor) => context.push(
                              DoctorDetail.route,
                              extra: doctor,
                            ),
                          ),
                    const Expanded(child: AhpsicoSpacing.verticalSpaceLarge),
                    Row(
                      children: [
                        HomeButton(
                          text: "CONFIRMAR",
                          enableFlex: true,
                          onPressed: model.emitConfirmSessionEvent,
                          color: AhpsicoColors.green,
                          icon: Icons.check_circle,
                        ),
                        AhpsicoSpacing.horizontalSpaceSmall,
                        HomeButton(
                          text: "CANCELAR",
                          enableFlex: true,
                          onPressed: model.emitCancelSessionEvent,
                          color: AhpsicoColors.red,
                          icon: Icons.cancel,
                        ),
                      ],
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
                    Row(
                      children: [
                        HomeButton(
                          text: "REMARCAR",
                          enableFlex: true,
                          onPressed: () {
                            context
                                .push<Session?>(
                              BookingScreen.route,
                              extra: BookingScreen.buildArgs(session: session),
                            )
                                .then((updatedSession) {
                              if (updatedSession != null) {
                                context.replace(SessionDetail.route, extra: updatedSession);
                              }
                            });
                          },
                          color: AhpsicoColors.blue,
                          icon: Icons.edit_calendar,
                        ),
                        AhpsicoSpacing.horizontalSpaceSmall,
                        HomeButton(
                          text: "CONCLUIR",
                          enableFlex: true,
                          onPressed: model.emitConcludeSessionEvent,
                          color: AhpsicoColors.violet,
                          icon: Icons.assignment_turned_in,
                        ),
                      ],
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
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
