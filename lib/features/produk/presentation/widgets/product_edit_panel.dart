import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/product.dart';
import 'product_margin_row.dart';

/// Panel edit produk (340 dp): nama, kategori, satuan, harga jual/modal, stok,
/// barcode, margin, status aktif. Beri `key: ValueKey(product.id)` agar isian
/// dimuat ulang saat produk terpilih berganti.
class ProductEditPanel extends StatefulWidget {
  const ProductEditPanel({
    super.key,
    required this.product,
    required this.onSave,
    required this.onClose,
  });

  final Product product;
  final ValueChanged<Product> onSave;
  final VoidCallback onClose;

  @override
  State<ProductEditPanel> createState() => _ProductEditPanelState();
}

class _ProductEditPanelState extends State<ProductEditPanel> {
  late final _name = TextEditingController(text: widget.product.name);
  late final _unit = TextEditingController(text: widget.product.unit);
  late final _price = TextEditingController(
    text: formatRupiah(widget.product.price),
  );
  late final _cost = TextEditingController(
    text: formatRupiah(widget.product.costPrice),
  );
  late final _stock = TextEditingController(text: '${widget.product.stock}');
  late final _minStock = TextEditingController(
    text: '${widget.product.minStock}',
  );
  late final _barcode = TextEditingController(
    text: widget.product.barcode ?? '',
  );
  late String _category = widget.product.category;
  late bool _active = widget.product.isActive;

  @override
  void dispose() {
    for (final c in [
      _name,
      _unit,
      _price,
      _cost,
      _stock,
      _minStock,
      _barcode,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Product _draft({bool? active}) {
    final barcode = _barcode.text.trim();
    return widget.product.copyWith(
      name: _name.text.trim(),
      category: _category,
      unit: _unit.text.trim(),
      price: parseDigits(_price.text),
      costPrice: parseDigits(_cost.text),
      stock: parseDigits(_stock.text),
      minStock: parseDigits(_minStock.text),
      barcode: barcode.isEmpty ? null : barcode,
      isActive: active ?? _active,
    );
  }

  @override
  Widget build(BuildContext context) {
    const money = [RupiahInputFormatter()];
    final numeric = [FilteringTextInputFormatter.digitsOnly];
    final categories = productCategories.skip(1).toList();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit produk', style: context.text.titleMedium),
              IconButton(
                tooltip: 'Tutup panel',
                onPressed: widget.onClose,
                color: context.app.ink2,
                style: IconButton.styleFrom(
                  backgroundColor: context.colors.surfaceContainer,
                  minimumSize: const Size.square(AppSize.touch - AppSpacing.xs),
                ),
                icon: const AppIcon(AppIcons.close, size: AppSize.iconSm),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.sm,
                children: [
                  AppTextField(
                    dense: true,
                    label: 'Nama produk',
                    controller: _name,
                  ),
                  _pair(
                    AppDropdownField<String>(
                      dense: true,
                      label: 'Kategori',
                      value: categories.contains(_category)
                          ? _category
                          : categories.first,
                      items: categories,
                      onChanged: (v) =>
                          setState(() => _category = v ?? _category),
                    ),
                    AppTextField(
                      dense: true,
                      label: 'Satuan',
                      controller: _unit,
                    ),
                  ),
                  _pair(
                    AppTextField(
                      dense: true,
                      label: 'Harga jual',
                      controller: _price,
                      keyboardType: TextInputType.number,
                      inputFormatters: money,
                    ),
                    AppTextField(
                      dense: true,
                      label: 'Harga modal',
                      controller: _cost,
                      keyboardType: TextInputType.number,
                      inputFormatters: money,
                    ),
                  ),
                  _pair(
                    AppTextField(
                      dense: true,
                      label: 'Stok',
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      inputFormatters: numeric,
                    ),
                    AppTextField(
                      dense: true,
                      label: 'Stok minimum',
                      controller: _minStock,
                      keyboardType: TextInputType.number,
                      inputFormatters: numeric,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: AppSpacing.xs,
                    children: [
                      Expanded(
                        child: AppTextField(
                          dense: true,
                          label: 'Barcode (opsional)',
                          hint: 'Ketik atau scan',
                          controller: _barcode,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Scan barcode',
                        onPressed: () =>
                            showComingSoon(context, 'Scan barcode'),
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(AppSize.fieldDense),
                          side: BorderSide(color: context.app.borderInput),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.smAll,
                          ),
                        ),
                        icon: const AppIcon(
                          AppIcons.scan,
                          size: AppSize.iconMd,
                        ),
                      ),
                    ],
                  ),
                  MarginRow(
                    price: _price,
                    cost: _cost,
                    active: _active,
                    onActive: (v) => setState(() => _active = v),
                  ),
                ],
              ),
            ),
          ),
          Row(
            spacing: AppSpacing.xs,
            children: [
              AppButton(
                label: _active ? 'Nonaktifkan' : 'Aktifkan',
                variant: _active
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.secondary,
                size: AppButtonSize.medium,
                expand: false,
                onPressed: () {
                  setState(() => _active = !_active);
                  widget.onSave(_draft(active: _active));
                },
              ),
              Expanded(
                child: AppButton(
                  label: 'Simpan perubahan',
                  size: AppButtonSize.medium,
                  onPressed: () => widget.onSave(_draft()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pair(Widget left, Widget right) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      Expanded(child: left),
      Expanded(child: right),
    ],
  );
}
