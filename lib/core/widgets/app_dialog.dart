import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Membuka dialog di tengah layar. Tidak bisa ditutup dengan ketuk di luar
/// supaya isian yang sedang diketik tidak hilang tanpa sengaja.
Future<T?> showAppDialog<T>(BuildContext context, WidgetBuilder builder) =>
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: builder,
    );

/// Kerangka dialog: judul, isi yang bisa digulir, banner kesalahan, dan baris
/// aksi (Batal + aksi utama). Lebar mengikuti [AppLayout.dialogWidth].
///
/// Saat [isLoading], tombol utama menampilkan indikator, Batal dinonaktifkan,
/// dan dialog tidak bisa ditutup (mis. dengan tombol Back).
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.cancelLabel = 'Batal',
    this.onCancel,
    this.errorMessage,
    this.isLoading = false,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String primaryLabel;
  final VoidCallback? onPrimary;

  /// Null = tanpa tombol batal (mis. dialog yang hanya perlu "Selesai").
  final String? cancelLabel;

  /// Null = menutup dialog dengan `Navigator.pop`.
  final VoidCallback? onCancel;

  /// Kesalahan dari server; tampil sebagai banner di atas tombol.
  final String? errorMessage;
  final bool isLoading;

  /// Aksi utama berupa tindakan berisiko (mis. menonaktifkan).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.dialogWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleLarge),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                Flexible(child: SingleChildScrollView(child: child)),
                if (errorMessage != null) _ErrorBanner(errorMessage!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: AppSpacing.sm,
                  children: [
                    if (cancelLabel != null)
                      AppButton(
                        label: cancelLabel!,
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.medium,
                        expand: false,
                        onPressed: isLoading
                            ? null
                            : onCancel ?? () => Navigator.of(context).pop(),
                      ),
                    AppButton(
                      label: primaryLabel,
                      variant: destructive
                          ? AppButtonVariant.destructive
                          : AppButtonVariant.primary,
                      size: AppButtonSize.medium,
                      expand: false,
                      isLoading: isLoading,
                      onPressed: onPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: AppRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              AppIcon(
                AppIcons.alertTriangle,
                size: AppSize.iconMd,
                color: colors.error,
              ),
              Expanded(
                child: Text(
                  message,
                  style: context.text.bodySmall?.copyWith(color: colors.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
