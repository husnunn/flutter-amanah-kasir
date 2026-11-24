import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_input_decoration.dart';

/// Field teks dengan label di atas. [leading] = ikon di kiri, [trailing] =
/// widget di kanan (mis. tombol tampilkan password). [dense] = varian 42 dp
/// untuk panel samping.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.dense = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });

  final String? label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final AppIconData? leading;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool dense;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: dense ? AppSpacing.xxs : AppSpacing.xs,
      children: [
        if (label != null) FieldLabel(label!, dense: dense),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: dense ? context.text.bodyMedium : context.text.bodyLarge,
          decoration: appInputDecoration(
            context,
            dense: dense,
            hint: hint,
            leading: leading,
            trailing: trailing,
          ),
        ),
      ],
    );
  }
}
