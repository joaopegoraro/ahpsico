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
  });

  final Advice advice;
  final bool isUserDoctor;

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
        onTap: messageIsTooBig ? () => setState(() => isExpanded = !isExpanded) : null,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  if (messageIsTooBig)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                ],
              ),
              AhpsicoSpacing.verticalSpaceSmall,
              Text(
                !messageIsTooBig || isExpanded
                    ? widget.advice.message
                    : "${widget.advice.message.substring(0, math.min(widget.advice.message.length, 100))}...",
                style: AhpsicoText.regular3Style.copyWith(color: AhpsicoColors.dark50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
