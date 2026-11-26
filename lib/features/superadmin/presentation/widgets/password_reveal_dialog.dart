import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'superadmin_dialogs.dart';

/// Menampilkan password pengguna baru SEKALI. Setelah dialog ditutup password
/// tidak bisa dilihat lagi (hanya bisa diganti lewat tautan reset).
Future<void> showPasswordRevealDialog(
  BuildContext context, {
  required String name,
  required String email,
  required String password,
}) => showScopedDialog<void>(
  context,
  (_) => _PasswordRevealDialog(name: name, email: email, password: password),
);

class _PasswordRevealDialog extends StatefulWidget {
  const _PasswordRevealDialog({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  State<_PasswordRevealDialog> createState() => _PasswordRevealDialogState();
}

class _PasswordRevealDialogState extends State<_PasswordRevealDialog> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.password));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    return AppDialog(
      title: 'Pengguna dibuat',
      subtitle: '${widget.name} · ${widget.email}',
      primaryLabel: 'Selesai',
      cancelLabel: null,
      onPrimary: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Text(
            'Berikan password ini kepada pengguna. Password hanya tampil sekali '
            'dan tidak bisa dilihat lagi setelah dialog ditutup.',
            style: text.bodyMedium?.copyWith(color: context.app.ink2),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.app.surfaceAlt,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: SelectableText(
                widget.password,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppSpacing.xxs,
                ),
              ),
            ),
          ),
          AppButton(
            label: _copied ? 'Tersalin' : 'Salin password',
            icon: _copied ? AppIcons.check : AppIcons.copy,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
            onPressed: _copy,
          ),
          Text(
            'Lupa mencatat? Kirim tautan reset password dari panel pengguna.',
            style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
