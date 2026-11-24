import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import 'widgets/login_parts.dart';

/// Login (HP): hero hijau di atas, lembar putih membulat yang menumpuk di
/// bawahnya. Tidak ada tombol daftar: akun dibuat oleh pengelola aplikasi.
///
/// Layar ini tidak tahu soal Firebase: ia memanggil [onSubmit] dan menampilkan
/// [isLoading], [errorMessage] (kegagalan login), serta [notice] (sesi ditolak).
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSubmit,
    this.onForgotPassword,
    this.isLoading = false,
    this.errorMessage,
    this.notice,
  });

  /// Dipanggil dengan email dan password yang sudah terisi.
  final void Function(String email, String password)? onSubmit;
  final VoidCallback? onForgotPassword;
  final bool isLoading;
  final String? errorMessage;
  final String? notice;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _localError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Isi email dan password.');
      return;
    }
    setState(() => _localError = null);
    TextInput.finishAutofillContext();
    widget.onSubmit?.call(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: ResponsiveCenter(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: AppLayout.loginHero,
              child: LoginHero(),
            ),
            Positioned.fill(
              top: AppLayout.loginHero - AppRadius.sheet,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.sheetTop,
                ),
                child: SafeArea(
                  top: false,
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: LoginForm(
                            email: _email,
                            password: _password,
                            obscure: _obscure,
                            isLoading: widget.isLoading,
                            message: _localError ?? widget.errorMessage,
                            notice: widget.notice,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            onSubmit: _submit,
                            onForgotPassword: widget.onForgotPassword,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
