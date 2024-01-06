import 'package:ahpsico/models/assignment.dart';
import 'package:ahpsico/constants/assignment_status.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

@immutable
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    required this.isUserDoctor,
  });

  final Assignment assignment;
  final void Function(Assignment)? onTap;
  final bool isUserDoctor;

  String get assignmentStatus => switch (assignment.status) {
        AssignmentStatus.done => "Concluída",
        AssignmentStatus.missed => "Não concluída",
        AssignmentStatus.pending => "Pendente",
      };

  Color get statusColor => switch (assignment.status) {
        AssignmentStatus.done => AhpsicoColors.green,
        AssignmentStatus.missed => AhpsicoColors.red,
        AssignmentStatus.pending => AhpsicoColors.yellow,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(assignment),
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
                      assignment.title,
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
                          "Status",
                          style: AhpsicoText.smallStyle
                              .copyWith(color: AhpsicoColors.light20),
                        ),
                        AhpsicoSpacing.horizontalSpaceSmall,
                        Chip(
                          backgroundColor: statusColor,
                          label: Text(
                            assignmentStatus,
                            style: AhpsicoText.smallStyle
                                .copyWith(color: AhpsicoColors.light80),
                          ),
                        ),
                      ],
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
                    Text(
                      "Para sessão de ${assignment.session.readableDate}",
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
