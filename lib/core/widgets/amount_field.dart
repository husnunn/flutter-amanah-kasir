import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import '../utils/formatters.dart';

/// Field nominal besar (28/800) berborder ink. Dua mode:
/// - [AmountField.display]: hanya menampilkan [text] (diisi lewat keypad);
/// - [AmountField.input]: bisa diketik, otomatis diformat "Rp 150.000".
class AmountField extends StatelessWidget {
  const AmountField.display({
    super.key,
    required this.label,
    required String this.text,
  }) : controller = null,
       onChanged = null;

  const AmountField.input({
    super.key,
    required this.label,
    required TextEditingController this.controller,
    this.onChanged,
  }) : text = null;

  final String label;
  final String? text;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.secondary;
    final style = context.text.displayMedium;
    final border = OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(color: ink, width: AppSize.borderMedium),
    );
    final decoration = InputDecoration(
      constraints: const BoxConstraints(minHeight: AppSize.amountField),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.app.ink2,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (text != null)
          Semantics(
            label: label,
            value: text,
            child: InputDecorator(
              decoration: decoration,
              child: Text(text!, style: style, maxLines: 1),
            ),
          )
        else
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: style,
            keyboardType: TextInputType.number,
            inputFormatters: const [RupiahInputFormatter()],
            decoration: decoration.copyWith(hintText: formatRupiah(0)),
          ),
      ],
    );
  }
}
