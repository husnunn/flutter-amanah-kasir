import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Layar tunggu saat status sesi / data toko dimuat.
class GateSplash extends StatelessWidget {
  const GateSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.lg,
          children: [
            LogoMark(size: LogoSize.lg),
            SizedBox.square(
              dimension: AppSize.iconXl,
              child: CircularProgressIndicator(
                strokeWidth: AppSize.borderThick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gagal memuat data toko: coba lagi atau keluar.
class GateError extends StatelessWidget {
  const GateError({super.key, required this.onRetry, required this.onSignOut});

  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: StateView(
                icon: AppIcons.alertTriangle,
                title: 'Tidak bisa memuat data toko',
                message: 'Periksa koneksi internet Anda, lalu coba lagi.',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.sm,
                children: [
                  AppButton(label: 'Coba lagi', onPressed: onRetry),
                  AppButton(
                    label: 'Keluar',
                    variant: AppButtonVariant.secondary,
                    onPressed: onSignOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
