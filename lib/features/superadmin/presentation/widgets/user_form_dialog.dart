import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/data/app_role.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import '../../data/superadmin_failure.dart';
import '../../state/superadmin_providers.dart';
import 'password_reveal_dialog.dart';
import 'superadmin_dialogs.dart';
import 'user_form_fields.dart';

/// Dialog tambah/ubah pengguna. [user] null = pengguna baru; [presetStoreId]
/// mengisi toko awal (dari tombol "Tambah pengguna" di panel toko).
///
/// Untuk pengguna baru, password dibuat otomatis lalu ditampilkan sekali
/// setelah berhasil. Mengembalikan uid yang disimpan, atau null bila batal.
Future<String?> showUserFormDialog(
  BuildContext context, {
  ManagedUser? user,
  String? presetStoreId,
  required String currentUid,
}) async {
  final result = await showScopedDialog<_Saved>(
    context,
    (_) => _UserFormDialog(
      user: user,
      presetStoreId: presetStoreId,
      isSelf: user != null && user.uid == currentUid,
    ),
  );
  if (result == null) return null;
  final password = result.password;
  if (password != null && context.mounted) {
    await showPasswordRevealDialog(
      context,
      name: result.name,
      email: result.email,
      password: password,
    );
  }
  return result.uid;
}

class _Saved {
  const _Saved(this.uid, this.name, this.email, this.password);

  final String uid;
  final String name;
  final String email;
  final String? password;
}

const _roleOrder = [AppRole.kasir, AppRole.admin, AppRole.superadmin];

class _UserFormDialog extends ConsumerStatefulWidget {
  const _UserFormDialog({
    required this.user,
    required this.presetStoreId,
    required this.isSelf,
  });

  final ManagedUser? user;
  final String? presetStoreId;
  final bool isSelf;

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  late final _name = TextEditingController(text: widget.user?.name);
  late final _email = TextEditingController(text: widget.user?.email);
  late AppRole _role = widget.user?.role ?? AppRole.kasir;
  late String? _kasirStore =
      widget.user?.storeIds.firstOrNull ?? widget.presetStoreId;
  late final Set<String> _adminStores = {
    ...?widget.user?.storeIds,
    ?widget.presetStoreId,
  };

  Map<String, String> _errors = const {};
  String? _serverError;
  bool _saving = false;

  bool get _isEdit => widget.user != null;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  List<String> _storeIds(List<StoreRecord> stores) {
    if (widget.isSelf) return widget.user!.storeIds;
    return switch (_role) {
      AppRole.superadmin => const [],
      AppRole.kasir => [?_kasirStore],
      AppRole.admin => [
        for (final s in stores)
          if (_adminStores.contains(s.id)) s.id,
      ],
    };
  }

  Future<void> _submit(List<StoreRecord> stores) async {
    final draft = UserDraft(
      uid: widget.user?.uid,
      name: _name.text,
      email: _email.text,
      role: widget.isSelf ? widget.user!.role : _role,
      storeIds: _storeIds(stores),
      password: _isEdit ? null : PasswordGenerator.generate(),
    );
    final errors = validateUserDraft(draft);
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() {
      _errors = const {};
      _serverError = null;
      _saving = true;
    });
    try {
      final uid = await ref.read(superadminRepositoryProvider).saveUser(draft);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(_Saved(uid, draft.name.trim(), draft.email.trim(), draft.password));
    } on SuperadminFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (failure.isDuplicate) {
          _errors = {'email': failure.message};
        } else {
          _serverError = failure.message;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverError = 'Terjadi kendala. Coba lagi.';
      });
    }
  }

  /// Toko yang bisa dipilih: yang aktif, ditambah yang sudah dipegang pengguna
  /// ini (agar tidak hilang diam-diam walau tokonya sedang nonaktif).
  List<StoreRecord> _selectable(List<StoreRecord> stores) {
    final current = widget.user?.storeIds ?? const <String>[];
    return [
      for (final s in stores)
        if (s.isActive || current.contains(s.id)) s,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(managedStoresProvider).value ?? const [];
    final stores = _selectable(all);
    final muted = context.text.labelMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final noStores = stores.isEmpty && _role != AppRole.superadmin;

    return AppDialog(
      title: _isEdit ? 'Edit pengguna' : 'Tambah pengguna',
      subtitle: _isEdit ? widget.user!.email : 'Akun baru langsung aktif.',
      primaryLabel: 'Simpan',
      isLoading: _saving,
      errorMessage: _serverError,
      onPrimary: noStores ? null : () => _submit(all),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          AppTextField(
            label: 'Nama lengkap *',
            hint: 'Mis. Rina Wati',
            controller: _name,
            textInputAction: TextInputAction.next,
            errorText: _errors['name'],
          ),
          AppTextField(
            label: 'Email *',
            hint: 'nama@toko.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            errorText: _errors['email'],
          ),
          if (widget.isSelf)
            Text('Peran dan toko akun Anda tidak bisa diubah.', style: muted)
          else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                const FieldLabel('Peran *'),
                SegmentedTabs(
                  labels: [for (final r in _roleOrder) r.label],
                  selectedIndex: _roleOrder.indexOf(_role),
                  expand: true,
                  onChanged: (i) => setState(() => _role = _roleOrder[i]),
                ),
              ],
            ),
            if (noStores)
              Text(
                'Belum ada toko aktif. Tambah toko dulu sebelum membuat '
                'admin atau kasir.',
                style: muted,
              )
            else
              UserStoreFields(
                role: _role,
                stores: stores,
                kasirStore: _kasirStore,
                adminStores: _adminStores,
                errorText: _errors['stores'],
                onKasirChanged: (id) => setState(() => _kasirStore = id),
                onAdminToggle: (id, checked) => setState(
                  () =>
                      checked ? _adminStores.add(id) : _adminStores.remove(id),
                ),
              ),
          ],
          Text(
            _isEdit
                ? 'Password tidak diubah. Untuk mengganti, kirim tautan reset '
                      'dari panel pengguna.'
                : 'Password dibuat otomatis dan ditampilkan sekali setelah '
                      'pengguna disimpan.',
            style: muted,
          ),
        ],
      ),
    );
  }
}
