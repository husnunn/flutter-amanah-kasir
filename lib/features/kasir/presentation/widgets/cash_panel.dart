import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/payment_controller.dart';

/// Isian tunai: uang diterima, tombol nominal cepat, dan kotak kembalian.
/// Angkanya diisi lewat keypad.
class CashPanel extends StatelessWidget {
  const CashPanel({super.key, required this.payment});

  final PaymentController payment;

  @override
  Widget build(BuildContext context) {
    final quick = <(String, int)>[
      ('Uang pas', payment.total),
      for (final amount in payment.quickAmounts) (formatRupiah(amount), amount),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        AmountField.display(
          label: 'Uang diterima',
          text: formatRupiah(payment.received),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          mainAxisExtent: AppSize.buttonSmall,
          children: [
            for (final (label, amount) in quick)
              _QuickAmount(
                label: label,
                selected: payment.received == amount,
                onTap: () => payment.setReceived(amount),
              ),
          ],
        ),
        _ChangeBox(payment: payment),
      ],
    );
  }
}

class _QuickAmount extends StatelessWidget {
  const _QuickAmount({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      radius: AppRadius.mdAll,
      padding: EdgeInsets.zero,
      color: selected ? colors.secondary : colors.surface,
      borderColor: selected ? colors.secondary : colors.outline,
      child: Center(
        child: Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: selected ? colors.onSecondary : context.app.ink2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChangeBox extends StatelessWidget {
  const _ChangeBox({required this.payment});

  final PaymentController payment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final short = payment.total - payment.received;
    final enough = short <= 0;
    final foreground = enough ? colors.onPrimaryContainer : colors.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: enough ? colors.primaryContainer : colors.errorContainer,
        borderRadius: AppRadius.xlAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: AppSpacing.sm,
          children: [
            Text(
              enough ? 'Kembalian' : 'Kurang',
              style: context.text.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatRupiah(enough ? payment.change : short),
                  style: context.text.displayLarge?.copyWith(color: foreground),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pengganti isian tunai untuk QRIS/transfer: hanya dicatat sebagai metode bayar.
class NonCashNotice extends StatelessWidget {
  const NonCashNotice({super.key, required this.payment});

  final PaymentController payment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.xlAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            AppIcon(
              payment.method.icon,
              size: AppSize.iconHero,
              color: colors.primary,
            ),
            Text(
              '${payment.method.label} dicatat sebagai metode bayar',
              style: context.text.titleMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            Text(
              'Pastikan pembayaran ${formatRupiah(payment.total)} sudah diterima '
              'sebelum menyelesaikan transaksi.',
              style: context.text.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
