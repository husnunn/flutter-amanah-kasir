import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class PaymentHeader extends StatelessWidget {
  const PaymentHeader({
    super.key,
    required this.storeName,
    required this.cashierName,
    required this.receiptNo,
    required this.onBack,
  });

  final String storeName;
  final String cashierName;
  final String receiptNo;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenPadding,
            vertical: AppSpacing.md,
          ),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              IconButton(
                tooltip: 'Kembali ke pesanan',
                onPressed: onBack,
                color: colors.onSurface,
                style: IconButton.styleFrom(
                  minimumSize: const Size.square(AppSize.touch),
                  side: BorderSide(color: colors.outline),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                icon: const AppIcon(AppIcons.chevronLeft),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pembayaran', style: context.text.headlineSmall),
                    Text(
                      '$storeName · Kasir: $cashierName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (context.isTablet)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(color: colors.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      receiptNo,
                      style: context.text.bodySmall?.copyWith(
                        color: context.app.ink2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
