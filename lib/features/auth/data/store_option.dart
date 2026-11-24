import '../../../core/theme/theme.dart';

/// Toko yang bisa dipilih admin setelah login.
class StoreOption {
  /// [id] = id dokumen toko di Firestore; bila kosong memakai [code].
  const StoreOption({
    String? id,
    required this.code,
    required this.name,
    required this.area,
    this.kasirLabel,
    this.salesToday,
    required this.tone,
    this.syncLabel = 'Tersinkron',
    this.online = true,
  }) : id = id ?? code;

  final String id;
  final String code;
  final String name;
  final String area;

  /// Opsional: belum tersedia dari dokumen toko, disembunyikan bila null.
  final String? kasirLabel;
  final int? salesToday;
  final ToneName tone;
  final String syncLabel;
  final bool online;
}

/// DATA CONTOH untuk mengisi tampilan; bukan data sungguhan.
const sampleStoreOptions = <StoreOption>[
  StoreOption(
    code: 'TK01',
    name: 'Toko Berkah Jaya',
    area: 'Surabaya',
    kasirLabel: '3 kasir',
    salesToday: 1620000,
    tone: ToneName.green,
  ),
  StoreOption(
    code: 'TK02',
    name: 'Warung Bu Sri',
    area: 'Sidoarjo',
    kasirLabel: '1 kasir',
    salesToday: 640000,
    tone: ToneName.amber,
  ),
  StoreOption(
    code: 'TK03',
    name: 'Kios Sembako Makmur',
    area: 'Gresik',
    kasirLabel: '2 kasir',
    salesToday: 0,
    tone: ToneName.blue,
    syncLabel: 'Offline sejak 09.40',
    online: false,
  ),
];
