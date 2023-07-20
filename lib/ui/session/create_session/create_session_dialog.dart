import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({
    super.key,
    required this.dateTime,
    required this.onConfirm,
  });

  final DateTime dateTime;
  final void Function(bool isChecked) onConfirm;

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: Wrap(
        children: [
          Column(
            children: [
              Text(
                "Tem certeza que deseja agendar uma sessão para "
                "${TimeUtils.getReadableDate(widget.dateTime)}, "
                "às ${TimeUtils.getDateAsHours(widget.dateTime)}?",
              ),
              AhpsicoSpacing.verticalSpaceMedium,
              const Text("Escolha se a sessão que você está agendando é mensal, ou individual."),
              AhpsicoSpacing.verticalSpaceMedium,
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isChecked = !_isChecked;
              });
            },
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Checkbox(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: _isChecked,
                    fillColor: const MaterialStatePropertyAll(AhpsicoColors.violet),
                    onChanged: null,
                  ),
                  AhpsicoSpacing.horizontalSpaceSmall,
                  const Text("Sessão mensal"),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => widget.onConfirm(_isChecked),
          child: Text(
            "Confirmar",
            textAlign: TextAlign.end,
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            "Cancelar",
            textAlign: TextAlign.end,
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
