import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Tata letak halaman kelola (toko atau pengguna): kiri berisi judul + tombol
/// tambah, kartu ringkasan, pencarian, dan tabel; kanan panel detail 340 dp.
class ManagementLayout extends StatelessWidget {
  const ManagementLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.stats,
    required this.search,
    required this.table,
    this.filter,
    this.panel,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  /// Kartu ringkasan (biasanya tiga `StatCard`), dibagi lebar sama rata.
  final List<Widget> stats;
  final Widget search;
  final Widget? filter;
  final Widget table;
  final Widget? panel;

  @override
  Widget build(BuildContext context) {
    return MinHeightScroll(
      minHeight: AppLayout.managementMinHeight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          spacing: AppSpacing.lg,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.headlineMedium,
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        label: actionLabel,
                        icon: AppIcons.plus,
                        size: AppButtonSize.small,
                        expand: false,
                        onPressed: onAction,
                      ),
                    ],
                  ),
                  Row(
                    spacing: AppSpacing.sm,
                    children: [for (final stat in stats) Expanded(child: stat)],
                  ),
                  search,
                  ?filter,
                  Expanded(child: table),
                ],
              ),
            ),
            if (panel != null)
              SizedBox(width: AppLayout.editPanel, child: panel),
          ],
        ),
      ),
    );
  }
}
