import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';

@immutable
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Doutora Andréa",
                    style: AhpsicoText.regular1Style.copyWith(
                      color: AhpsicoColors.dark75,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AhpsicoSpacing.verticalSpaceSmall,
                  Text(
                    MaskFormatters.phoneMaskFormatter
                        .maskText("(47) 99968-1790"),
                    style: AhpsicoText.regular3Style.copyWith(
                      color: AhpsicoColors.light20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
