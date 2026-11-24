import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/store_option.dart';

/// Pilih toko (HP): muncul setelah login untuk admin yang mengelola lebih dari
/// satu toko. Kartu toko bergaya radio; toko aktif bisa diganti dari dashboard.
class PilihTokoScreen extends StatefulWidget {
  const PilihTokoScreen({
    super.key,
    this.userName = 'Sari Ayu',
    this.stores = sampleStoreOptions,
    this.onConfirm,
  });

  final String userName;
  final List<StoreOption> stores;
  final ValueChanged<StoreOption>? onConfirm;

  @override
  State<PilihTokoScreen> createState() => _PilihTokoScreenState();
}

class _PilihTokoScreenState extends State<PilihTokoScreen> {
  late StoreOption _selected = widget.stores.first;
  String _query = '';

  List<StoreOption> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.stores;
    return widget.stores
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final muted = context.colors.onSurfaceVariant;
    final visible = _visible;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPhone,
              AppSpacing.xl,
              AppSpacing.screenPhone,
              AppSpacing.screenPhone,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs,
                  children: [
                    Text(
                      'Halo, ${widget.userName}',
                      style: text.bodyMedium?.copyWith(color: muted),
                    ),
                    Text('Pilih toko', style: text.headlineLarge),
                    Text(
                      'Anda mengelola ${widget.stores.length} toko. '
                      'Toko aktif bisa diganti kapan saja dari dashboard.',
                      style: text.bodyMedium?.copyWith(color: context.app.ink3),
                    ),
                  ],
                ),
                AppTextField(
                  hint: 'Cari toko',
                  leading: AppIcons.search,
                  onChanged: (v) => setState(() => _query = v),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const StateView(
                          icon: AppIcons.store,
                          title: 'Toko tidak ditemukan',
                          message: 'Coba kata kunci lain.',
                        )
                      : ListView.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, i) => _StoreCard(
                            store: visible[i],
                            selected: visible[i].code == _selected.code,
                            onTap: () => setState(() => _selected = visible[i]),
                          ),
                        ),
                ),
                AppButton(
                  label: 'Masuk ke ${_selected.name}',
                  onPressed: () => widget.onConfirm?.call(_selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final StoreOption store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final subtitle = [
      store.area,
      store.kasirLabel,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AppCard(
        onTap: onTap,
        borderColor: selected ? colors.primary : colors.outline,
        borderWidth: selected ? AppSize.borderThick : AppSize.borderThin,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            InitialBlock(
              label: store.code,
              tone: store.tone,
              width: AppSize.touch,
              height: AppSize.touch,
              radius: AppRadius.mdAll,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xxs,
                children: [
                  Text(store.name, style: text.titleSmall),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: text.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Wrap(
                      spacing: AppSpacing.md,
                      children: [
                        if (store.salesToday != null)
                          Text.rich(
                            TextSpan(
                              text: 'Hari ini ',
                              children: [
                                TextSpan(
                                  text: formatRupiah(store.salesToday!),
                                  style: text.labelMedium?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            style: text.labelMedium?.copyWith(
                              color: context.app.ink3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          store.syncLabel,
                          style: text.labelMedium?.copyWith(
                            color: store.online
                                ? colors.primary
                                : context.app.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.primary : colors.surface,
        border: selected
            ? null
            : Border.all(
                color: context.app.borderInput,
                width: AppSize.borderThick,
              ),
      ),
      child: SizedBox.square(
        dimension: AppSize.iconLg,
        child: selected
            ? Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: AppSpacing.xs),
                ),
              )
            : null,
      ),
    );
  }
}
