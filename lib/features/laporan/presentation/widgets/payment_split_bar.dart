import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../data/dashboard_data.dart';

/// Bar bertumpuk pendapatan per metode bayar dengan legenda persen + nominal.
class PaymentSplitBar extends StatelessWidget {
  const PaymentSplitBar({super.key, required this.shares});

  final List<PaymentShare> shares;

  Color _color(BuildContext context, PaymentKind kind) => switch (kind) {
    PaymentKind.cash => context.colors.primary,
    PaymentKind.qris => context.app.info,
    PaymentKind.transfer => context.app.warning,
  };

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(
          'Per metode pembayaran',
          style: text.bodySmall?.copyWith(
            color: context.app.ink2,
            fontWeight: FontWeight.w600,
          ),
        ),
        ClipRRect(
          borderRadius: AppRadius.fullAll,
          child: Row(
            spacing: 2,
            children: [
              for (final s in shares)
                Expanded(
                  flex: s.percent,
                  child: ColoredBox(
                    color: _color(context, s.kind),
                    child: const SizedBox(height: AppSize.splitBar),
                  ),
                ),
            ],
          ),
        ),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.xs,
          children: [
            for (final s in shares)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _color(context, s.kind),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.xxs),
                      ),
                    ),
                    child: const SizedBox.square(dimension: AppSize.legendDot),
                  ),
                  Text(
                    '${s.label} ${s.percent}% · ${s.amountLabel}',
                    style: text.labelMedium?.copyWith(
                      color: context.app.ink3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
