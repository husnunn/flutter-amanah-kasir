import 'package:material_ui/material_ui.dart';

import '../app/app_router.dart';
import '../core/theme/theme.dart';
import '../core/widgets/widgets.dart';

/// Halaman awal pratinjau: daftar semua layar dari spesifikasi UI. Layout
/// tablet/HP dipilih otomatis dari lebar layar (>= 900 dp = tablet).
class ScreenGallery extends StatelessWidget {
  const ScreenGallery({super.key, this.router = const AppRouter()});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sections = <_Section>[
      _Section('Kasir', [
        _Entry(
          'Kasir',
          'Pilih produk, atur pesanan, bayar',
          AppIcons.shoppingBag,
          ['Tablet', 'HP'],
          router.kasir,
        ),
        _Entry(
          'Pembayaran',
          'Metode bayar, uang diterima, kembalian',
          AppIcons.cash,
          ['Tablet', 'HP'],
          router.pembayaranContoh,
        ),
        _Entry(
          'Transaksi berhasil',
          'Pratinjau nota, cetak ulang, WhatsApp',
          AppIcons.receipt,
          ['HP'],
          router.transaksiBerhasilContoh,
        ),
      ]),
      _Section('Admin', [
        _Entry(
          'Dashboard',
          'Saldo kotor/bersih, grafik, stok menipis',
          AppIcons.dashboard,
          ['Tablet', 'HP'],
          router.dashboard,
        ),
        _Entry(
          'Kelola produk',
          'Daftar produk dan panel edit',
          AppIcons.package,
          ['Tablet'],
          router.produk,
        ),
        _Entry(
          'Catat pengeluaran',
          'Nominal, kategori, tanggal, foto bukti',
          AppIcons.wallet,
          ['HP'],
          () => router.pengeluaran(prefilled: true),
        ),
      ]),
      _Section('Login & Superadmin', [
        _Entry('Login', 'Email dan password', AppIcons.lock, [
          'HP',
        ], router.login),
        _Entry(
          'Pilih toko',
          'Untuk admin dengan lebih dari satu toko',
          AppIcons.store,
          ['HP'],
          router.pilihToko,
        ),
        _Entry('Toko & pengguna', 'Kelola toko dan pengguna', AppIcons.users, [
          'Tablet',
        ], router.tokoPengguna),
      ]),
    ];

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: ListView(
            padding: EdgeInsets.all(context.screenPadding),
            children: [
              const SizedBox(height: AppSpacing.md),
              const Align(
                alignment: Alignment.centerLeft,
                child: LogoMark(size: LogoSize.md),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Amanah Kasir', style: context.text.headlineMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Pratinjau UI · data contoh, belum terhubung ke backend.',
                style: context.text.bodyMedium?.copyWith(
                  color: context.app.ink3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  'Lebar ${width.round()} dp · layout ${context.isTablet ? 'tablet' : 'HP'}',
                  tone: BadgeTone.info,
                ),
              ),
              for (final section in sections) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(section.title, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final entry in section.entries) ...[
                  _EntryTile(entry: entry),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  const _Section(this.title, this.entries);

  final String title;
  final List<_Entry> entries;
}

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.devices, this.route);

  final String title;
  final String subtitle;
  final AppIconData icon;
  final List<String> devices;
  final Route<void> Function() route;
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: () => Navigator.of(context).push(entry.route()),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: AppRadius.mdAll,
            ),
            child: SizedBox.square(
              dimension: AppSize.touch,
              child: Center(child: AppIcon(entry.icon, color: colors.primary)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: context.text.titleSmall),
                Text(
                  entry.subtitle,
                  style: context.text.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AppSpacing.xxs,
            children: [
              for (final d in entry.devices)
                StatusBadge(
                  d,
                  tone: d == 'Tablet' ? BadgeTone.success : BadgeTone.neutral,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
