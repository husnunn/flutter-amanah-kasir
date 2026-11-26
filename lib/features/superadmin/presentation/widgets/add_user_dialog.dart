import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/new_user_input.dart';
import '../../data/store_record.dart';
import '../../data/superadmin_repository.dart';

/// Membuka dialog "Tambah pengguna". Mengembalikan nama pengguna yang
/// berhasil dibuat, atau null bila dibatalkan.
Future<String?> showAddUserDialog(
  BuildContext context, {
  required List<StoreRecord> stores,
  required CreateUser onSubmit,
  String? initialStoreId,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AddUserDialog(
      stores: stores,
      initialStoreId: initialStoreId,
      onSubmit: onSubmit,
    ),
  );
}

/// Formulir pengguna baru: nama, email, password, peran, dan toko.
/// Kasir terikat ke tepat satu toko; admin boleh mengelola beberapa toko.
class AddUserDialog extends StatefulWidget {
  const AddUserDialog({
    super.key,
    required this.stores,
    required this.onSubmit,
    this.initialStoreId,
  });

  final List<StoreRecord> stores;
  final String? initialStoreId;
  final CreateUser onSubmit;

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  UserRole _role = UserRole.kasir;
  late final Set<String> _selected = {
    if (widget.initialStoreId != null) widget.initialStoreId!,
  };
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Toko terpilih menurut urutan daftar, bukan urutan klik.
  List<String> get _storeIds => [
    for (final s in widget.stores)
      if (_selected.contains(s.id)) s.id,
  ];

  void _setRole(UserRole role) {
    setState(() {
      _role = role;
      // Kasir hanya satu toko: pertahankan yang pertama.
      if (role == UserRole.kasir && _selected.length > 1) {
        final keep = _storeIds.first;
        _selected
          ..clear()
          ..add(keep);
      }
    });
  }

  void _toggleStore(String id, bool selected) {
    setState(() {
      if (_role == UserRole.kasir) {
        _selected
          ..clear()
          ..add(id);
      } else if (selected) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final input = NewUserInput(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      role: _role,
      storeIds: _storeIds,
    );
    final problem = input.validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(input);
      if (mounted) Navigator.of(context).pop(input.cleanName);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error is SuperadminFailure
            ? error.message
            : 'Gagal menambah pengguna. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return PopScope(
      canPop: !_submitting,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Text('Tambah pengguna', style: text.titleLarge),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.md,
                      children: [
                        AppTextField(
                          label: 'Nama',
                          hint: 'Nama lengkap',
                          leading: AppIcons.user,
                          controller: _name,
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          label: 'Email',
                          hint: 'nama@email.com',
                          leading: AppIcons.mail,
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        AppTextField(
                          label: 'Password',
                          hint:
                              'Minimal ${NewUserInput.minPasswordLength} '
                              'karakter',
                          leading: AppIcons.lock,
                          controller: _password,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          trailing: IconButton(
                            tooltip: _obscure
                                ? 'Tampilkan password'
                                : 'Sembunyikan password',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            color: colors.onSurfaceVariant,
                            icon: AppIcon(
                              _obscure ? AppIcons.eye : AppIcons.eyeOff,
                              size: AppSize.iconMd,
                            ),
                          ),
                        ),
                        const FieldLabel('Peran'),
                        SegmentedTabs(
                          labels: [for (final r in UserRole.values) r.label],
                          selectedIndex: UserRole.values.indexOf(_role),
                          expand: true,
                          onChanged: (i) => _setRole(UserRole.values[i]),
                        ),
                        FieldLabel(
                          _role == UserRole.kasir
                              ? 'Toko (pilih satu)'
                              : 'Toko yang dikelola',
                        ),
                        for (final store in widget.stores)
                          CheckboxListTile(
                            key: ValueKey('toko-${store.id}'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _selected.contains(store.id),
                            onChanged: _submitting
                                ? null
                                : (v) => _toggleStore(store.id, v ?? false),
                            title: Text(
                              '${store.code} · ${store.name}'
                              '${store.active ? '' : ' (nonaktif)'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (_error != null)
                          Text(
                            _error!,
                            style: text.bodySmall?.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Batal',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.medium,
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Simpan',
                        size: AppButtonSize.medium,
                        isLoading: _submitting,
                        onPressed: _submit,
                      ),
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
