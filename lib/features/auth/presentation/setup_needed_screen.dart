import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Tampil bila `firebase_options.dart` masih placeholder: menjelaskan cara
/// menyambungkan project Firebase atau memakai emulator/galeri.
class SetupNeededScreen extends StatelessWidget {
  const SetupNeededScreen({super.key});

  static const _steps = <(String, String)>[
    (
      'Sambungkan project Firebase',
      'Ikuti docs/firebase-setup.md, lalu jalankan '
          '"flutterfire configure --platforms=android '
          '--android-package-name=id.amanah.kasir".',
    ),
    (
      'Atau coba dengan emulator',
      'Jalankan Firebase Emulator di komputer, lalu '
          '"flutter run --dart-define=USE_EMULATOR=true".',
    ),
    (
      'Atau lihat tampilannya saja',
      'Jalankan "flutter run --dart-define=GALLERY=true" untuk membuka '
          'galeri layar dengan data contoh.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: EdgeInsets.all(context.screenPadding),
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Align(
                alignment: Alignment.centerLeft,
                child: LogoMark(size: LogoSize.md),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Firebase belum disiapkan', style: text.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Aplikasi ini belum terhubung ke project Firebase. '
                'Pilih salah satu cara berikut.',
                style: text.bodyMedium?.copyWith(color: context.app.ink3),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final (index, step) in _steps.indexed) ...[
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.md,
                    children: [
                      InitialAvatar(
                        '${index + 1}',
                        avatarStyle: AvatarStyle.dark,
                        size: AppSpacing.xxl,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSpacing.xxs,
                          children: [
                            Text(step.$1, style: text.titleSmall),
                            Text(
                              step.$2,
                              style: text.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
