import 'package:ahpsico/models/user.dart';
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
    this.showSelected,
    this.onLongPress,
  });

  final User patient;
  final bool isSelected;
  final bool? showSelected;
  final void Function(User)? onTap;
  final void Function(User)? onLongPress;

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
          padding: showSelected ?? isSelected
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
                child: showSelected ?? isSelected
                    ? Row(children: [
                        Checkbox(
                          value: isSelected,
                          fillColor: const MaterialStatePropertyAll(AhpsicoColors.violet),
                          onChanged: null,
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
