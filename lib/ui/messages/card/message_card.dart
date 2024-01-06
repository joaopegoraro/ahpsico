import 'dart:math' as math;
import 'package:ahpsico/models/message.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

@immutable
class MessageCard extends StatefulWidget {
  const MessageCard({
    super.key,
    required this.message,
    required this.isUserDoctor,
    required this.showTitle,
    this.selectModeOn = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  final Message message;
  final bool isUserDoctor;
  final bool selectModeOn;
  final bool isSelected;
  final bool showTitle;
  final void Function(Message)? onTap;
  final void Function(Message)? onLongPress;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isExpanded = false;
  late final bool messageIsTooBig;

  @override
  void initState() {
    super.initState();
    messageIsTooBig = widget.message.text.length >= 100;
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
            ? () => widget.onTap?.call(widget.message)
            : messageIsTooBig
                ? () => setState(() => isExpanded = !isExpanded)
                : null,
        onLongPress: widget.onLongPress == null
            ? null
            : () => widget.onLongPress?.call(widget.message),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.selectModeOn && widget.isSelected
                    ? Row(
                        children: [
                          Checkbox(
                            value: widget.isSelected,
                            fillColor: const MaterialStatePropertyAll(
                                AhpsicoColors.violet),
                            onChanged: null,
                          ),
                          AhpsicoSpacing.horizontalSpaceSmall,
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (messageIsTooBig)
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    AhpsicoSpacing.verticalSpaceTiny,
                    Text(
                      !messageIsTooBig || isExpanded
                          ? widget.message.text
                          : "${widget.message.text.substring(0, math.min(widget.message.text.length, 100))}...",
                      style: AhpsicoText.regular3Style
                          .copyWith(color: AhpsicoColors.dark50),
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
