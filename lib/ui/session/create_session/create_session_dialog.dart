import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({
    super.key,
    required this.onConfirm,
  });

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
      content: Column(
        children: [
          const Text("Escolha se a sessão que você está agendando é mensal, ou individual."),
          AhpsicoSpacing.verticalSpaceSmall,
          const Text(
            "Caso deseje que a sessão seja mensal, 4 sessões serão criadas nas próximas semanas, "
            "todas no dia e horário selecionados. Após confirmar, você é livre para remarcar o "
            "horário ou o dia dessas sessões indo até a tela de sessões e encontrando a sessão desejada.",
          ),
          AhpsicoSpacing.verticalSpaceMedium,
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
                    value: _isChecked,
                    fillColor: const MaterialStatePropertyAll(AhpsicoColors.violet),
                    onChanged: (value) => _isChecked = value ?? false,
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
