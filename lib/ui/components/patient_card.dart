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
    this.isSelected = false,
    this.onLongPress,
  });

  final Patient patient;
  final bool isSelected;
  final void Function(Patient)? onTap;
  final void Function(Patient)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(patient),
        onLongPress: onLongPress == null ? null : () => onLongPress!(patient),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: isSelected
              ? const EdgeInsets.only(
                  right: 8,
                  top: 8,
                  bottom: 8,
                )
              : const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSelected
                    ? Row(children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: AhpsicoColors.violet,
                          onChanged: (_) {},
                        ),
                        AhpsicoSpacing.horizontalSpaceSmall,
                      ])
                    : const SizedBox.shrink(),
              ),
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
