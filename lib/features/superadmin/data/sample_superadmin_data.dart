import '../../auth/data/app_role.dart';
import 'managed_user.dart';
import 'store_record.dart';

/// Id pengguna "pemilik aplikasi" pada data contoh (akun yang sedang masuk).
const String sampleOwnerUid = 'u-owner';

/// DATA CONTOH untuk galeri dan tes; bukan data sungguhan.
final sampleStores = <StoreRecord>[
  _store('tk01', 'TK01', 'Toko Berkah Jaya', 'Jl. Raya Darmo 12, Surabaya', 2),
  _store('tk02', 'TK02', 'Warung Bu Sri', 'Jl. Pahlawan 5, Sidoarjo', 9),
  _store('tk03', 'TK03', 'Kios Sembako Makmur', 'Jl. Veteran 20, Gresik', 12),
  _store('tk04', 'TK04', 'Toko Sumber Rejeki', 'Jl. Ijen 8, Malang', 14),
  _store('tk05', 'TK05', 'Warung Kopi Pojok', 'Jl. Kertajaya 3, Surabaya', 16),
  _store('tk06', 'TK06', 'Minimarket Sinar', 'Jl. Majapahit 41, Mojokerto', 18),
  _store(
    'tk07',
    'TK07',
    'Toko Kelontong Ijo',
    'Jl. Wahid Hasyim 7, Jombang',
    19,
    isActive: false,
  ),
  _store(
    'tk08',
    'TK08',
    'Depot Mie Barokah',
    'Jl. Gajah Mada 15, Pasuruan',
    22,
  ),
];

/// Transaksi bulan ini per id toko (data contoh).
const sampleMonthlyTransactions = <String, int>{
  'tk01': 1284,
  'tk02': 412,
  'tk03': 268,
  'tk04': 351,
  'tk05': 190,
  'tk06': 520,
  'tk07': 0,
  'tk08': 96,
};

final sampleUsers = <ManagedUser>[
  _user(sampleOwnerUid, 'Pemilik Aplikasi', AppRole.superadmin, []),
  _user('u-sari', 'Sari Ayu', AppRole.admin, ['tk01', 'tk02', 'tk03']),
  _user('u-hendra', 'Hendra', AppRole.admin, ['tk04', 'tk05']),
  _user('u-lestari', 'Lestari', AppRole.admin, ['tk06', 'tk07']),
  _user('u-agus', 'Agus', AppRole.admin, ['tk08']),
  _user('u-rina', 'Rina Wati', AppRole.kasir, ['tk01']),
  _user('u-budi', 'Budi Santoso', AppRole.kasir, ['tk01']),
  _user('u-tono', 'Tono', AppRole.kasir, ['tk01']),
  _user('u-sri', 'Sri Rahayu', AppRole.kasir, ['tk02']),
  _user('u-dewi', 'Dewi', AppRole.kasir, ['tk03']),
  _user('u-fajar', 'Fajar', AppRole.kasir, ['tk03']),
  _user('u-lilis', 'Lilis', AppRole.kasir, ['tk04']),
  _user('u-yoga', 'Yoga', AppRole.kasir, ['tk04']),
  _user('u-nur', 'Nur', AppRole.kasir, ['tk05']),
  _user('u-anton', 'Anton', AppRole.kasir, ['tk06']),
  _user('u-bayu', 'Bayu', AppRole.kasir, ['tk06']),
  _user('u-citra', 'Citra', AppRole.kasir, ['tk06']),
  _user('u-dimas', 'Dimas', AppRole.kasir, ['tk06'], isActive: false),
  _user('u-ijah', 'Ijah', AppRole.kasir, ['tk07']),
  _user('u-eni', 'Mbak Eni', AppRole.kasir, ['tk08']),
  _user('u-joko', 'Pak Joko', AppRole.kasir, ['tk08']),
];

StoreRecord _store(
  String id,
  String code,
  String name,
  String address,
  int dayOfNovember, {
  bool isActive = true,
}) => StoreRecord(
  id: id,
  code: code,
  name: name,
  address: address,
  phone: '0812-3456-78$dayOfNovember',
  isActive: isActive,
  scanEnabled: id != 'tk02',
  createdAt: DateTime(2026, 11, dayOfNovember),
);

ManagedUser _user(
  String uid,
  String name,
  AppRole role,
  List<String> storeIds, {
  bool isActive = true,
}) => ManagedUser(
  uid: uid,
  name: name,
  email: '${name.toLowerCase().replaceAll(' ', '.')}@amanah.test',
  role: role,
  storeIds: storeIds,
  isActive: isActive,
);
