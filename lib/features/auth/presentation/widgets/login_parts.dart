import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return SizedBox(
      height: AppLayout.loginHero,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxxl,
            AppSpacing.xl,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.lg,
            children: [
              const LogoMark(size: LogoSize.lg, inverted: true),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    'Kasir untuk\nsemua toko Anda',
                    style: text.displayMedium?.copyWith(
                      color: colors.onPrimary,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Catat penjualan, cetak nota, dan pantau laba dari satu aplikasi.',
                    style: text.bodyMedium?.copyWith(
                      color: context.app.onAccentMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.email,
    required this.password,
    required this.obscure,
    required this.isLoading,
    required this.message,
    required this.notice,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool isLoading;
  final String? message;
  final String? notice;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Text('Masuk', style: context.text.headlineSmall),
          AppTextField(
            label: 'Email',
            hint: 'nama@email.com',
            leading: AppIcons.mail,
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          AppTextField(
            label: 'Password',
            hint: 'Masukkan password',
            leading: AppIcons.lock,
            controller: password,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onSubmit(),
            trailing: IconButton(
              tooltip: obscure ? 'Tampilkan password' : 'Sembunyikan password',
              onPressed: onToggleObscure,
              color: context.colors.onSurfaceVariant,
              icon: AppIcon(
                obscure ? AppIcons.eye : AppIcons.eyeOff,
                size: AppSize.iconMd,
              ),
            ),
          ),
          if (message != null)
            LoginFormMessage(message!, isError: true)
          else if (notice != null)
            LoginFormMessage(notice!, isError: false),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text('Lupa password?'),
            ),
          ),
          AppButton(label: 'Masuk', isLoading: isLoading, onPressed: onSubmit),
          const Spacer(),
          Text(
            'Akun kasir dan admin dibuat oleh pengelola aplikasi. '
            'Hubungi pemilik toko jika belum punya akun.',
            textAlign: TextAlign.center,
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pesan di bawah form: merah untuk kegagalan login, amber untuk sesi ditolak.
class LoginFormMessage extends StatelessWidget {
  const LoginFormMessage(this.text, {super.key, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.app;
    final foreground = isError ? colors.error : app.warning;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isError ? colors.errorContainer : app.warningSoft,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isError ? app.dangerBorder : app.warningBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              AppIcon(
                AppIcons.alertTriangle,
                size: AppSize.iconMd,
                color: foreground,
              ),
              Expanded(
                child: Text(
                  text,
                  style: context.text.bodySmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
