import '../../../core/theme/theme.dart';

/// Produk toko. Field mengikuti kamus data PRD (harga jual, harga modal, stok).
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.stock,
    required this.tone,
    this.minStock = 5,
    this.unit = 'pcs',
    this.barcode,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String sku;
  final String category;
  final int price;
  final int costPrice;
  final int stock;
  final int minStock;
  final String unit;
  final String? barcode;
  final ToneName tone;

  /// Hapus produk = nonaktif, agar riwayat transaksi tetap aman (PRD).
  final bool isActive;

  bool get isLowStock => stock <= minStock;

  /// Laba per item (harga jual - harga modal).
  int get margin => price - costPrice;

  Product copyWith({
    String? name,
    String? category,
    int? price,
    int? costPrice,
    int? stock,
    int? minStock,
    String? unit,
    String? barcode,
    bool? isActive,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      tone: tone,
      isActive: isActive ?? this.isActive,
    );
  }
}

const productCategories = <String>[
  'Semua',
  'Makanan',
  'Minuman',
  'Sembako',
  'Kebersihan',
  'Lainnya',
];

/// DATA CONTOH untuk mengisi tampilan; bukan data sungguhan.
const sampleProducts = <Product>[
  Product(
    id: 'mi-instan',
    name: 'Mi Instan Goreng',
    sku: 'SKU-0012',
    barcode: '8998866200',
    category: 'Makanan',
    price: 3500,
    costPrice: 2800,
    stock: 120,
    tone: ToneName.amber,
  ),
  Product(
    id: 'air-mineral',
    name: 'Air Mineral 600 ml',
    sku: 'SKU-0031',
    category: 'Minuman',
    price: 4000,
    costPrice: 3000,
    stock: 86,
    tone: ToneName.blue,
  ),
  Product(
    id: 'beras',
    name: 'Beras Premium 5 kg',
    sku: 'SKU-0101',
    category: 'Sembako',
    price: 74000,
    costPrice: 68000,
    stock: 12,
    minStock: 6,
    unit: 'karung',
    tone: ToneName.slate,
  ),
  Product(
    id: 'minyak',
    name: 'Minyak Goreng 1 L',
    sku: 'SKU-0104',
    category: 'Sembako',
    price: 18500,
    costPrice: 16500,
    stock: 6,
    minStock: 12,
    unit: 'liter',
    tone: ToneName.amber,
  ),
  Product(
    id: 'gula',
    name: 'Gula Pasir 1 kg',
    sku: 'SKU-0102',
    category: 'Sembako',
    price: 17000,
    costPrice: 15000,
    stock: 30,
    unit: 'kg',
    tone: ToneName.violet,
  ),
  Product(
    id: 'teh-botol',
    name: 'Teh Botol 350 ml',
    sku: 'SKU-0034',
    category: 'Minuman',
    price: 4000,
    costPrice: 3000,
    stock: 48,
    tone: ToneName.rose,
  ),
  Product(
    id: 'kopi-sachet',
    name: 'Kopi Sachet',
    sku: 'SKU-0033',
    category: 'Minuman',
    price: 1500,
    costPrice: 1100,
    stock: 200,
    tone: ToneName.slate,
  ),
  Product(
    id: 'telur',
    name: 'Telur Ayam 1 kg',
    sku: 'SKU-0108',
    category: 'Sembako',
    price: 28000,
    costPrice: 24500,
    stock: 3,
    minStock: 10,
    unit: 'kg',
    tone: ToneName.amber,
  ),
  Product(
    id: 'sabun',
    name: 'Sabun Mandi 85 g',
    sku: 'SKU-0210',
    category: 'Kebersihan',
    price: 3500,
    costPrice: 2700,
    stock: 40,
    tone: ToneName.green,
  ),
  Product(
    id: 'roti',
    name: 'Roti Tawar',
    sku: 'SKU-0045',
    category: 'Makanan',
    price: 15000,
    costPrice: 12500,
    stock: 4,
    minStock: 8,
    tone: ToneName.rose,
  ),
  Product(
    id: 'kerupuk',
    name: 'Kerupuk Udang',
    sku: 'SKU-0015',
    category: 'Makanan',
    price: 2000,
    costPrice: 1500,
    stock: 60,
    tone: ToneName.violet,
  ),
  Product(
    id: 'es-teh',
    name: 'Es Teh Manis',
    sku: 'SKU-0036',
    category: 'Minuman',
    price: 3000,
    costPrice: 1800,
    stock: 99,
    tone: ToneName.green,
  ),
];
