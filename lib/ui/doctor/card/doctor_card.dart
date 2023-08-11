import 'dart:math' as math;
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';

@immutable
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final User doctor;
  final void Function(User)? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(doctor),
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
                      doctor.name,
                      style: AhpsicoText.regular1Style.copyWith(
                        color: AhpsicoColors.dark75,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (doctor.description.isNotEmpty) ...[
                      AhpsicoSpacing.verticalSpaceSmall,
                      Text(
                        doctor.description.length > 100
                            ? "${doctor.description.substring(0, math.min(doctor.description.length, 100))}..."
                            : doctor.description,
                        style: AhpsicoText.regular3Style.copyWith(
                          color: AhpsicoColors.dark75,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    AhpsicoSpacing.verticalSpaceSmall,
                    Text(
                      MaskFormatters.phoneMaskFormatter.maskText(doctor.phoneNumber.substring(3)),
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
