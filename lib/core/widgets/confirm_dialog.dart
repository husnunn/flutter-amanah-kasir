import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'app_dialog.dart';

/// Dialog konfirmasi singkat. Mengembalikan true bila pengguna menyetujui,
/// false bila membatalkan. [destructive] memberi tombol utama gaya berisiko.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showAppDialog<bool>(
    context,
    (context) => AppDialog(
      title: title,
      primaryLabel: confirmLabel,
      destructive: destructive,
      onPrimary: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
      child: Text(
        message,
        style: context.text.bodyMedium?.copyWith(color: context.app.ink2),
      ),
    ),
  );
  return confirmed ?? false;
}
