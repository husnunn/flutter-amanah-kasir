import '../../../core/theme/theme.dart';
import 'store_option.dart';

/// Toko dari dokumen `stores/{id}` (kamus data PRD).
class StoreInfo {
  const StoreInfo({
    required this.id,
    required this.code,
    required this.name,
    this.address = '',
    this.isActive = true,
    this.scanEnabled = false,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final bool isActive;
  final bool scanEnabled;

  factory StoreInfo.fromMap(String id, Map<String, dynamic> data) => StoreInfo(
    id: id,
    code: (data['code'] as String?) ?? id.toUpperCase(),
    name: (data['name'] as String?) ?? id,
    address: (data['address'] as String?) ?? '',
    isActive: data['isActive'] != false,
    scanEnabled: data['scanEnabled'] == true,
  );

  /// Bentuk untuk kartu di layar Pilih toko. Jumlah kasir dan penjualan hari
  /// ini belum tersedia dari dokumen toko, jadi dikosongkan.
  StoreOption toOption(int index) => StoreOption(
    id: id,
    code: code,
    name: name,
    area: address,
    tone: ToneName.values[index % ToneName.values.length],
  );
}
