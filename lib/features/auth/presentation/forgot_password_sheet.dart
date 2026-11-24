import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../state/auth_providers.dart';

/// Bottom sheet "Lupa password?": mengirim email reset lewat Firebase Auth.
Future<void> showForgotPasswordSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const ForgotPasswordSheet(),
  );
}

class ForgotPasswordSheet extends ConsumerStatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  final _email = TextEditingController();
  bool _sending = false;
  String? _error;
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Isi email akun Anda.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final error = await ref
        .read(loginControllerProvider.notifier)
        .sendPasswordReset(email);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = error;
      _sentTo = error == null ? email : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final sent = _sentTo != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPhone,
        0,
        AppSpacing.screenPhone,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Text('Lupa password?', style: text.titleMedium),
          Text(
            'Masukkan email akun Anda. Kami kirim tautan untuk membuat '
            'password baru.',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (sent)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: AppRadius.mdAll,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.sm,
                  children: [
                    AppIcon(AppIcons.check, color: colors.primary),
                    Expanded(
                      child: Text(
                        'Tautan reset dikirim ke $_sentTo. Periksa kotak '
                        'masuk atau folder spam.',
                        style: text.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            AppTextField(
              label: 'Email',
              hint: 'nama@email.com',
              leading: AppIcons.mail,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _send(),
            ),
          if (_error != null)
            Text(
              _error!,
              style: text.bodySmall?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          AppButton(
            label: sent ? 'Selesai' : 'Kirim tautan reset',
            isLoading: _sending,
            onPressed: sent ? () => Navigator.of(context).pop() : _send,
          ),
        ],
      ),
    );
  }
}
