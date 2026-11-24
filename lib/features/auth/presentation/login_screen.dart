import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Login (HP): hero hijau di atas, lembar putih membulat yang menumpuk di
/// bawahnya. Tidak ada tombol daftar: akun dibuat oleh pengelola aplikasi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onSubmit});

  /// Dipanggil saat tombol Masuk ditekan.
  final VoidCallback? onSubmit;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

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
              child: _LoginHero(),
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
                          child: _LoginForm(
                            obscure: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            onSubmit: widget.onSubmit,
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

class _LoginHero extends StatelessWidget {
  const _LoginHero();

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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Text('Masuk', style: context.text.headlineSmall),
        const AppTextField(
          label: 'Email',
          hint: 'nama@email.com',
          leading: AppIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: [AutofillHints.email],
        ),
        AppTextField(
          label: 'Password',
          hint: 'Masukkan password',
          leading: AppIcons.lock,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Lupa password?'),
          ),
        ),
        AppButton(label: 'Masuk', onPressed: onSubmit ?? () {}),
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
    );
  }
}
