import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/cart_controller.dart';

/// Bar pesanan hijau di atas navigasi bawah (HP): ringkasan item, total, dan
/// tombol "Lihat pesanan". Tersembunyi saat keranjang kosong.
class OrderBar extends StatelessWidget {
  const OrderBar({super.key, required this.cart, required this.onTap});

  final CartController cart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) return const SizedBox.shrink();
        final colors = context.colors;
        final text = context.text;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Semantics(
            button: true,
            label:
                'Lihat pesanan, ${cart.itemCount} item, ${formatRupiah(cart.total)}',
            child: Material(
              color: colors.primary,
              borderRadius: AppRadius.xlAll,
              child: InkWell(
                borderRadius: AppRadius.xlAll,
                onTap: onTap,
                child: SizedBox(
                  height: AppSize.orderBar,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.xs,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cart.itemCount} item · ${cart.productCount} produk',
                                style: text.labelMedium?.copyWith(
                                  color: context.app.onAccentMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatRupiah(cart.total),
                                style: text.titleLarge?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.onPrimaryContainer,
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: SizedBox(
                            height: AppSize.fieldDense,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: AppSpacing.xxs,
                                children: [
                                  Text(
                                    'Lihat pesanan',
                                    style: text.bodyMedium?.copyWith(
                                      color: colors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AppIcon(
                                    AppIcons.chevronRight,
                                    size: AppSize.iconSm,
                                    color: colors.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
