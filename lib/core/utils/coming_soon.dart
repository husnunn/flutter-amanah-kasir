import 'package:material_ui/material_ui.dart';

/// Menu yang belum ada di desain menampilkan snackbar ini.
void showComingSoon(BuildContext context, [String? feature]) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          feature == null ? 'Segera hadir' : '$feature segera hadir',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}
