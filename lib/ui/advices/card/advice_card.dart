import 'dart:math' as math;
import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

@immutable
class AdviceCard extends StatefulWidget {
  const AdviceCard({
    super.key,
    required this.advice,
    required this.isUserDoctor,
    required this.showTitle,
    this.selectModeOn = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  final Advice advice;
  final bool isUserDoctor;
  final bool selectModeOn;
  final bool isSelected;
  final bool showTitle;
  final void Function(Advice)? onTap;
  final void Function(Advice)? onLongPress;

  @override
  State<AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<AdviceCard> {
  bool isExpanded = false;
  late final bool messageIsTooBig;

  @override
  void initState() {
    super.initState();
    messageIsTooBig = widget.advice.message.length >= 100;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AhpsicoColors.light80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: widget.selectModeOn
            ? () => widget.onTap?.call(widget.advice)
            : messageIsTooBig
                ? () => setState(() => isExpanded = !isExpanded)
                : null,
        onLongPress: widget.onLongPress == null ? null : () => widget.onLongPress?.call(widget.advice),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.selectModeOn && widget.isSelected
                    ? Row(children: [
                        Checkbox(
                          value: widget.isSelected,
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
                    Row(
                      children: [
                        if (widget.showTitle)
                          Expanded(
                            child: Text(
                              widget.isUserDoctor
                                  ? "Enviado para ${widget.advice.patientIds.length} paciente(s)"
                                  : widget.advice.doctor.name,
                              style: AhpsicoText.regular1Style.copyWith(
                                color: AhpsicoColors.dark75,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (!widget.showTitle && messageIsTooBig) const Spacer(),
                        if (messageIsTooBig)
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                      ],
                    ),
                    Text(
                      !messageIsTooBig || isExpanded
                          ? widget.advice.message
                          : "${widget.advice.message.substring(0, math.min(widget.advice.message.length, 100))}...",
                      style: AhpsicoText.regular3Style.copyWith(color: AhpsicoColors.dark50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
