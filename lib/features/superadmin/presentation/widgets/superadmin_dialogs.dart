import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/superadmin_failure.dart';

/// Membuka dialog yang tetap bisa membaca provider layar ini. Dialog dipasang
/// di Navigator (di luar pohon layar), jadi container Riverpod dibawa masuk
/// agar override (mis. repositori contoh) ikut berlaku.
Future<T?> showScopedDialog<T>(BuildContext context, WidgetBuilder builder) {
  final container = ProviderScope.containerOf(context);
  return showAppDialog<T>(
    context,
    (_) => UncontrolledProviderScope(
      container: container,
      child: Builder(builder: builder),
    ),
  );
}

/// Menjalankan [action]; kegagalan tampil sebagai snackbar. Mengembalikan true
/// bila berhasil.
Future<bool> runSuperadminAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  void notify(String message) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
  try {
    await action();
    if (successMessage != null) notify(successMessage);
    return true;
  } on SuperadminFailure catch (failure) {
    notify(failure.message);
  } catch (_) {
    notify('Terjadi kendala. Coba lagi.');
  }
  return false;
}
