import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_icon.dart';

/// Dekorasi field standar aplikasi: garis tipis, radius 12 (10 untuk [dense]),
/// garis hijau saat fokus. Dipakai bersama oleh field teks dan dropdown.
InputDecoration appInputDecoration(
  BuildContext context, {
  bool dense = false,
  String? hint,
  AppIconData? leading,
  Widget? trailing,
}) {
  final colors = context.colors;
  final app = context.app;
  final radius = dense ? AppRadius.smAll : AppRadius.mdAll;
  OutlineInputBorder border(Color color, [double width = AppSize.borderThin]) =>
      OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    isDense: dense,
    constraints: BoxConstraints(
      minHeight: dense ? AppSize.fieldDense : AppSize.field,
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: dense ? AppSpacing.sm : AppSpacing.md,
      vertical: dense ? AppSpacing.xs : AppSpacing.sm,
    ),
    prefixIcon: leading == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.sm,
            ),
            child: AppIcon(leading, size: AppSize.iconMd),
          ),
    prefixIconConstraints: const BoxConstraints(),
    suffixIcon: trailing,
    suffixIconConstraints: const BoxConstraints(),
    border: border(app.borderInput),
    enabledBorder: border(app.borderInput),
    focusedBorder: border(colors.primary, AppSize.borderMedium),
  );
}

/// Label kecil di atas field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.dense = false});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: (dense ? context.text.labelMedium : context.text.bodySmall)
          ?.copyWith(color: context.app.ink2, fontWeight: FontWeight.w600),
    );
  }
}

/// Dropdown dengan label di atas dan gaya yang sama dengan [AppTextField].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.dense = false,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: dense ? AppSpacing.xxs : AppSpacing.xs,
      children: [
        FieldLabel(label, dense: dense),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          onChanged: onChanged,
          icon: const AppIcon(AppIcons.chevronDown, size: AppSize.iconMd),
          borderRadius: AppRadius.mdAll,
          style: dense ? context.text.bodyMedium : context.text.bodyLarge,
          decoration: appInputDecoration(context, dense: dense),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel?.call(item) ?? '$item'),
              ),
          ],
        ),
      ],
    );
  }
}
