import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/store_record.dart';
import '../../data/superadmin_failure.dart';
import '../../state/superadmin_providers.dart';
import 'detail_parts.dart';
import 'superadmin_dialogs.dart';

/// Dialog tambah/ubah toko. [store] null = toko baru dengan kode awal
/// [suggestedCode]. Mengembalikan id toko yang disimpan, atau null bila batal.
Future<String?> showStoreFormDialog(
  BuildContext context, {
  StoreRecord? store,
  required String suggestedCode,
}) => showScopedDialog<String>(
  context,
  (_) => _StoreFormDialog(store: store, suggestedCode: suggestedCode),
);

class _StoreFormDialog extends ConsumerStatefulWidget {
  const _StoreFormDialog({required this.store, required this.suggestedCode});

  final StoreRecord? store;
  final String suggestedCode;

  @override
  ConsumerState<_StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends ConsumerState<_StoreFormDialog> {
  late final _name = TextEditingController(text: widget.store?.name);
  late final _code = TextEditingController(
    text: widget.store?.code ?? widget.suggestedCode,
  );
  late final _address = TextEditingController(text: widget.store?.address);
  late final _phone = TextEditingController(text: widget.store?.phone);
  late bool _scanEnabled = widget.store?.scanEnabled ?? false;

  Map<String, String> _errors = const {};
  String? _serverError;
  bool _saving = false;

  bool get _isEdit => widget.store != null;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final draft = StoreDraft(
      id: widget.store?.id,
      code: _code.text,
      name: _name.text,
      address: _address.text,
      phone: _phone.text,
      scanEnabled: _scanEnabled,
    );
    final errors = validateStoreDraft(draft);
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
      final id = await ref.read(superadminRepositoryProvider).saveStore(draft);
      if (mounted) Navigator.of(context).pop(id);
    } on SuperadminFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (failure.isDuplicate) {
          _errors = {'code': failure.message};
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

  @override
  Widget build(BuildContext context) {
    final muted = context.text.labelMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return AppDialog(
      title: _isEdit ? 'Edit data toko' : 'Tambah toko',
      subtitle: _isEdit
          ? 'Kode toko tidak bisa diubah.'
          : 'Toko baru langsung aktif.',
      primaryLabel: 'Simpan',
      isLoading: _saving,
      errorMessage: _serverError,
      onPrimary: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: 'Kode toko *',
                  controller: _code,
                  readOnly: _isEdit,
                  trailing: _isEdit
                      ? const Padding(
                          padding: EdgeInsets.only(right: AppSpacing.md),
                          child: AppIcon(AppIcons.lock, size: AppSize.iconMd),
                        )
                      : null,
                  inputFormatters: [_UpperCaseFormatter()],
                  textInputAction: TextInputAction.next,
                  errorText: _errors['code'],
                ),
              ),
              Expanded(
                flex: 5,
                child: AppTextField(
                  label: 'Nama toko *',
                  hint: 'Mis. Toko Berkah Jaya',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  errorText: _errors['name'],
                ),
              ),
            ],
          ),
          if (!_isEdit)
            Text(
              'Kode dipakai di nomor nota dan tidak bisa diubah setelah dibuat.',
              style: muted,
            ),
          AppTextField(
            label: 'Alamat',
            hint: 'Jalan, kota',
            controller: _address,
            textInputAction: TextInputAction.next,
            errorText: _errors['address'],
          ),
          AppTextField(
            label: 'Telepon',
            hint: '0812-3456-7890',
            controller: _phone,
            keyboardType: TextInputType.phone,
            errorText: _errors['phone'],
          ),
          ActiveSwitchRow(
            label: 'Scan barcode dengan kamera',
            value: _scanEnabled,
            onChanged: (v) => setState(() => _scanEnabled = v),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
