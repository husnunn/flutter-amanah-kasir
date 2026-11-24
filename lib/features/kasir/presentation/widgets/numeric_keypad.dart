import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Papan angka 3 x 4: 1-9, 000, 0, hapus. Mengirim digit ke [onDigits].
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigits,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigits;
  final VoidCallback onBackspace;

  static const _keys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '000',
    '0',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisExtent: AppSize.keypadKey,
      children: [
        for (final key in _keys)
          _Key(
            semanticLabel: key,
            onTap: () => onDigits(key),
            child: Text(key, style: context.text.headlineMedium),
          ),
        _Key(
          semanticLabel: 'Hapus angka',
          background: context.colors.surfaceContainer,
          onTap: onBackspace,
          child: const AppIcon(AppIcons.backspace, size: AppSize.iconLg),
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.background,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: AppCard(
          onTap: onTap,
          radius: AppRadius.lgAll,
          padding: EdgeInsets.zero,
          color: background,
          child: Center(child: child),
        ),
      ),
    );
  }
}
