import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/constants/session_payment_status.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/booking/booking_screen.dart';
import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/doctor/card/doctor_card.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/card/patient_card.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail.dart';
import 'package:ahpsico/ui/session/detail/session_detail_model.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionDetail extends StatelessWidget {
  const SessionDetail(
    this._session, {
    super.key,
  });

  static const route = "/session/detail";

  final Session _session;

  Session _getSession(SessionDetailModel model) {
    return model.updatedSession ?? _session;
  }

  void _onEventEmitted(
    BuildContext context,
    SessionDetailModel model,
    SessionDetailEvent event,
  ) {
    final session = _getSession(model);
    switch (event) {
      case SessionDetailEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case SessionDetailEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case SessionDetailEvent.navigateToLogin:
        context.go(LoginScreen.route);
      case SessionDetailEvent.cancelSession:
      case SessionDetailEvent.concludeSession:
      case SessionDetailEvent.confirmSession:
      case SessionDetailEvent.paySession:
        AhpsicoDialog.show(
          context: context,
          content: switch (event) {
            SessionDetailEvent.cancelSession =>
              "Tem certeza que deseja cancelar a sessão?\n"
                  "Isso não poderá ser desfeito.",
            SessionDetailEvent.concludeSession =>
              "Tem certeza que deseja marcar a sessão "
                  "como concluída?\nIsso não poderá ser desfeito.",
            SessionDetailEvent.confirmSession =>
              "Tem certeza que deseja confirmar a sessão?",
            SessionDetailEvent.paySession =>
              "Tem certeza que deseja marcar a sessão como paga?\n"
                  "Isso não poderá ser desfeito.",
            _ => "",
          },
          onTapFirstButton: () {
            context.pop();
            switch (event) {
              case SessionDetailEvent.cancelSession:
                model.cancelSession(session);
              case SessionDetailEvent.concludeSession:
                model.concludeSession(session);
              case SessionDetailEvent.confirmSession:
                model.confirmSession(session);
              case SessionDetailEvent.paySession:
                model.paySession(session);
              default:
                null;
            }
          },
          firstButtonText: switch (event) {
            SessionDetailEvent.cancelSession => "Sim, cancelar a sessão",
            SessionDetailEvent.concludeSession => "Sim, marcar como concluída",
            SessionDetailEvent.confirmSession => "Sim, confirmar a sessão",
            SessionDetailEvent.paySession => "Sim, marcar como paga",
            _ => "",
          },
          secondButtonText: "Não, fechar",
        );
      case SessionDetailEvent.rescheduleSession:
        context
            .push<Session?>(BookingScreen.route,
                extra: BookingScreen.buildArgs(session: session))
            .then((updatedSession) {
          if (updatedSession != null) {
            model.setUpdatedSession(updatedSession);
          }
        });
    }
  }

  String _getSessionStatus(SessionStatus status) {
    return switch (status) {
      SessionStatus.canceled => "Cancelada",
      SessionStatus.concluded => "Concluída",
      SessionStatus.confirmed => "Confirmada",
      SessionStatus.notConfirmed => "Não confirmada",
      SessionStatus.confirmedByDoctor => "Não confirmada pelo paciente",
      SessionStatus.confirmedByPatient => "Não confirmada pela doutora",
    };
  }

  Color _getStatusColor(SessionStatus status) {
    return switch (status) {
      SessionStatus.canceled => AhpsicoColors.red,
      SessionStatus.concluded => AhpsicoColors.violet,
      SessionStatus.confirmed => AhpsicoColors.green,
      _ => AhpsicoColors.yellow
    };
  }

  String _getSessionPaymentStatus(SessionPaymentStatus status) =>
      switch (status) {
        SessionPaymentStatus.notPayed => "Não paga",
        SessionPaymentStatus.payed => "Paga",
      };

  Color _getPaymentStatusColor(Session session) =>
      switch (session.paymentStatus) {
        SessionPaymentStatus.notPayed => AhpsicoColors.red,
        SessionPaymentStatus.payed => AhpsicoColors.green,
        null => AhpsicoColors.yellow,
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
            onBackPressed: () {
              if (model.updatedSession != null) {
                context.go(LoginScreen.route);
              } else {
                context.pop();
              }
            });
      },
      fabBuilder: (context, model) {
        final session = _getSession(model);
        if (session.status.isOver) return null;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              backgroundColor: AhpsicoColors.blue,
              label: Text(
                "REMARCAR",
                style: AhpsicoText.regular2Style.copyWith(
                  color: AhpsicoColors.light80,
                ),
              ),
              onPressed: model.emitRescheduleSessionEvent,
              icon: const Icon(Icons.edit_calendar),
            ),
            AhpsicoSpacing.verticalSpaceSmall,
            if (model.user!.role.isDoctor &&
                session.paymentStatus?.isNotPayed == true)
              FloatingActionButton.extended(
                backgroundColor: AhpsicoColors.green,
                label: Text(
                  "MARCAR COMO PAGA",
                  style: AhpsicoText.regular2Style.copyWith(
                    color: AhpsicoColors.light80,
                  ),
                ),
                onPressed: model.emitPaySessionEvent,
                icon: const Icon(Icons.paid),
              ),
          ],
        );
      },
      bodyBuilder: (context, model) {
        final session = _getSession(model);
        final updateStatusOptions = SessionStatus.values.whereNot((status) {
          if (session.status == SessionStatus.notConfirmed) return false;
          return status == SessionStatus.notConfirmed;
        });
        return WillPopScope(
          onWillPop: () async {
            if (model.updatedSession != null) {
              context.go(LoginScreen.route);
              return false;
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${session.readableDate} às ${session.dateTime}",
                        style: AhpsicoText.title2Style.copyWith(
                          color: AhpsicoColors.dark25,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceSmall,
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: [
                          Chip(
                            backgroundColor: _getStatusColor(session.status),
                            label: Text(
                              _getSessionStatus(session.status),
                              style: AhpsicoText.regular1Style
                                  .copyWith(color: AhpsicoColors.light80),
                            ),
                          ),
                          if (session.paymentStatus != null)
                            Chip(
                              backgroundColor: _getPaymentStatusColor(session),
                              label: Text(
                                _getSessionPaymentStatus(
                                  session.paymentStatus!,
                                ),
                                style: AhpsicoText.regular1Style
                                    .copyWith(color: AhpsicoColors.light80),
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
                              patient: session.user,
                              onTap: (patient) => context.push(
                                PatientDetail.route,
                                extra: patient,
                              ),
                            )
                          : const DoctorCard(),
                      AhpsicoSpacing.verticalSpaceLarge,
                      if (!session.status.isOver)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Alterar status da sessão:",
                                style: AhpsicoText.regular1Style.copyWith(
                                  color: AhpsicoColors.dark50,
                                ),
                              ),
                            ),
                            AhpsicoSpacing.horizontalSpaceSmall,
                            DropdownButton(
                              value: session.status,
                              underline: const SizedBox.shrink(),
                              dropdownColor: Colors.transparent,
                              elevation: 0,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(28)),
                              items: updateStatusOptions.mapToList((status) {
                                final color = _getStatusColor(status);
                                return DropdownMenuItem(
                                  value: status,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(28)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          switch (status) {
                                            SessionStatus.canceled =>
                                              Icons.cancel,
                                            SessionStatus.confirmed =>
                                              Icons.check_circle,
                                            SessionStatus.concluded =>
                                              Icons.assignment_turned_in,
                                            _ => Icons.schedule,
                                          },
                                          color: AhpsicoColors.light80,
                                        ),
                                        AhpsicoSpacing.horizontalSpaceSmall,
                                        FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            _getSessionStatus(status),
                                            style: AhpsicoText.regular2Style
                                                .copyWith(
                                              color: AhpsicoColors.light80,
                                            ),
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              selectedItemBuilder: (context) {
                                return updateStatusOptions.mapToList((status) {
                                  final color = _getStatusColor(status);
                                  return Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 12, 16, 12),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(28)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          switch (session.status) {
                                            SessionStatus.canceled =>
                                              Icons.cancel,
                                            SessionStatus.confirmed =>
                                              Icons.check_circle,
                                            SessionStatus.concluded =>
                                              Icons.assignment_turned_in,
                                            _ => Icons.schedule,
                                          },
                                          color: AhpsicoColors.light80,
                                        ),
                                        AhpsicoSpacing.horizontalSpaceSmall,
                                        FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            _getSessionStatus(status),
                                            style: AhpsicoText.regular2Style
                                                .copyWith(
                                              color: AhpsicoColors.light80,
                                            ),
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                              onChanged: (status) {
                                if (status == session.status) return;
                                return switch (status) {
                                  SessionStatus.canceled =>
                                    model.emitCancelSessionEvent(),
                                  SessionStatus.concluded =>
                                    model.emitConcludeSessionEvent(),
                                  SessionStatus.confirmed =>
                                    model.emitConfirmSessionEvent(),
                                  _ => null,
                                };
                              },
                            ),
                          ],
                        ),
                      AhpsicoSpacing.verticalSpaceSmall,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
