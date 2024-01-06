import 'package:ahpsico/models/session.dart';
import 'package:ahpsico/constants/session_payment_status.dart';
import 'package:ahpsico/constants/session_status.dart';
import 'package:ahpsico/constants/session_type.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

@immutable
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.isUserDoctor,
  });

  final Session session;
  final void Function(Session)? onTap;
  final bool isUserDoctor;

  String get sessionStatus => switch (session.status) {
        SessionStatus.canceled => "Cancelada",
        SessionStatus.concluded => "Concluída",
        SessionStatus.confirmed => "Confirmada",
        SessionStatus.notConfirmed => "Não confirmada",
        SessionStatus.confirmedByDoctor => "Não confirmada pelo paciente",
        SessionStatus.confirmedByPatient => "Não confirmada pela doutora",
      };

  Color get statusColor => switch (session.status) {
        SessionStatus.canceled => AhpsicoColors.red,
        SessionStatus.concluded => AhpsicoColors.violet,
        SessionStatus.confirmed => AhpsicoColors.green,
        _ => AhpsicoColors.yellow
      };

  String get sessionPaymentStatus => switch (session.paymentStatus) {
        SessionPaymentStatus.notPayed => "Não paga",
        SessionPaymentStatus.payed => "Paga",
        null => session.paymentType.isClinic
            ? "Paga na clínica"
            : "Pago por convênio",
      };

  Color get paymentStatusColor => switch (session.paymentStatus) {
        SessionPaymentStatus.notPayed => AhpsicoColors.red,
        SessionPaymentStatus.payed => AhpsicoColors.green,
        null => AhpsicoColors.green,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(session),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUserDoctor ? session.user.name : "Doutora Andréa",
                      style: AhpsicoText.regular1Style.copyWith(
                        color: AhpsicoColors.dark75,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          "Situação",
                          style: AhpsicoText.smallStyle
                              .copyWith(color: AhpsicoColors.light20),
                        ),
                        Chip(
                          backgroundColor: statusColor,
                          label: Text(
                            sessionStatus,
                            style: AhpsicoText.smallStyle.copyWith(
                              color: AhpsicoColors.light80,
                            ),
                          ),
                        ),
                        Chip(
                          backgroundColor: paymentStatusColor,
                          label: Text(
                            sessionPaymentStatus,
                            style: AhpsicoText.smallStyle.copyWith(
                              color: AhpsicoColors.light80,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (session.type == SessionType.monthly) ...[
                      AhpsicoSpacing.verticalSpaceSmall,
                      Text(
                        "Sessão ${session.groupIndex + 1} de 4",
                        style: AhpsicoText.regular3Style
                            .copyWith(color: AhpsicoColors.dark50),
                      ),
                    ],
                    AhpsicoSpacing.verticalSpaceSmall,
                    Text(
                      "${session.readableDate}, às ${session.dateTime}",
                      style: AhpsicoText.regular3Style
                          .copyWith(color: AhpsicoColors.dark50),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
