import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
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
  });

  final Session session;
  final void Function(Session)? onTap;

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
                      session.patient.name,
                      style: AhpsicoText.regular1Style.copyWith(
                        color: AhpsicoColors.dark75,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Situação",
                          style: AhpsicoText.smallStyle.copyWith(color: AhpsicoColors.light20),
                        ),
                        AhpsicoSpacing.horizontalSpaceSmall,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            color: statusColor,
                          ),
                          child: Text(
                            sessionStatus,
                            style: AhpsicoText.smallStyle.copyWith(color: AhpsicoColors.light80),
                          ),
                        ),
                      ],
                    ),
                    if (session.type == SessionType.monthly) ...[
                      AhpsicoSpacing.verticalSpaceSmall,
                      Text(
                        "Sessão ${session.groupIndex} de 4",
                        style: AhpsicoText.regular3Style.copyWith(color: AhpsicoColors.dark50),
                      ),
                    ],
                    AhpsicoSpacing.verticalSpaceSmall,
                    Text(
                      "${session.readableDate}, às ${session.dateTime}",
                      style: AhpsicoText.regular3Style.copyWith(color: AhpsicoColors.dark50),
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
