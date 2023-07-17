import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

@immutable
class AdviceCard extends StatelessWidget {
  const AdviceCard({
    super.key,
    required this.advice,
    required this.onTap,
    required this.isUserDoctor,
  });

  final Advice advice;
  final void Function(Advice)? onTap;
  final bool isUserDoctor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(advice),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUserDoctor ? "Enviado para ${advice.patientIds.length} paciente(s)" : advice.doctor.name,
                style: AhpsicoText.regular1Style.copyWith(
                  color: AhpsicoColors.dark75,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              Text(
                advice.message,
                style: AhpsicoText.regular3Style.copyWith(color: AhpsicoColors.dark50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
