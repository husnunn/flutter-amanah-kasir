import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';

class MarginRow extends StatelessWidget {
  const MarginRow({
    super.key,
    required this.price,
    required this.cost,
    required this.active,
    required this.onActive,
  });

  final TextEditingController price;
  final TextEditingController cost;
  final bool active;
  final ValueChanged<bool> onActive;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.app.surfaceAlt,
        borderRadius: AppRadius.smAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([price, cost]),
              builder: (context, _) => Text.rich(
                TextSpan(
                  text: 'Margin: ',
                  children: [
                    TextSpan(
                      text: formatRupiah(
                        parseDigits(price.text) - parseDigits(cost.text),
                      ),
                      style: text.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: text.bodySmall?.copyWith(color: context.app.ink2),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: active,
                  onChanged: (v) => onActive(v ?? active),
                ),
                Text(
                  'Aktif',
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
