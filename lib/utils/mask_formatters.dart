import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MaskFormatters {
  static const phoneMaskPattern = '+## (##) #####-####';

  static final phoneMaskFormatter = MaskTextInputFormatter(
    mask: phoneMaskPattern,
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );
}
