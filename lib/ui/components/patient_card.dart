import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';

@immutable
class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final Patient patient;
  final void Function(Patient)? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(patient),
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
                      patient.name,
                      style: AhpsicoText.regular1Style.copyWith(
                        color: AhpsicoColors.dark75,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
                    Text(
                      MaskFormatters.phoneMaskFormatter.maskText(patient.phoneNumber),
                      style: AhpsicoText.regular3Style.copyWith(
                        color: AhpsicoColors.light20,
                        fontWeight: FontWeight.w600,
                      ),
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
