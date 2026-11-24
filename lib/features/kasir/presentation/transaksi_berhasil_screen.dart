import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/receipt_data.dart';
import '../state/payment_controller.dart';
import 'widgets/receipt_preview.dart';

/// Transaksi berhasil: ringkasan, pratinjau nota, status printer, aksi.
class TransaksiBerhasilScreen extends StatelessWidget {
  const TransaksiBerhasilScreen({
    super.key,
    required this.receipt,
    this.printerLabel = 'Printer 58 mm terhubung',
    this.onNewTransaction,
    this.onClose,
  });

  final ReceiptData receipt;
  final String printerLabel;
  final VoidCallback? onNewTransaction;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final summary = [
      formatRupiah(receipt.total),
      receipt.method.label,
      if (receipt.method == PaymentMethod.cash)
        'Kembalian ${formatRupiah(receipt.change)}',
    ].join(' · ');

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPhone),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Tutup',
                    onPressed: onClose ?? onNewTransaction,
                    color: context.app.ink2,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      minimumSize: const Size.square(AppSize.touch),
                      side: BorderSide(color: colors.outline),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    icon: const AppIcon(AppIcons.close),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.md,
                      children: [
                        _SuccessHeader(summary: summary),
                        ReceiptPreview(data: receipt),
                        _PrinterStatus(label: printerLabel),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cetak ulang',
                        icon: AppIcons.printer,
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.medium,
                        onPressed: () =>
                            showComingSoon(context, 'Cetak ulang nota'),
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Kirim WhatsApp',
                        icon: AppIcons.send,
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.medium,
                        onPressed: () =>
                            showComingSoon(context, 'Kirim WhatsApp'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Transaksi baru',
                  onPressed: onNewTransaction ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      spacing: AppSpacing.xs,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: AppSize.amountField,
            child: Center(
              child: AppIcon(
                AppIcons.check,
                size: AppSize.iconHero,
                color: colors.onPrimary,
                strokeWidth: 2.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text('Transaksi berhasil', style: context.text.headlineMedium),
        Text(
          summary,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PrinterStatus extends StatelessWidget {
  const _PrinterStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: AppSpacing.xs),
        ),
        Text(
          'Nota tercetak · $label',
          style: context.text.labelMedium?.copyWith(
            color: colors.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
