import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store_record.dart';
import '../data/superadmin_repository.dart';

/// Repositori superadmin. Ditimpa dengan repositori palsu pada tes.
final superadminRepositoryProvider = Provider<SuperadminRepository>(
  (ref) => FirebaseSuperadminRepository(),
);

/// Semua toko beserta penggunanya, langsung dari Firestore.
///
/// Tanpa percobaan ulang otomatis: layar punya tombol "Coba lagi" sendiri.
final storeRecordsProvider = StreamProvider.autoDispose<List<StoreRecord>>(
  (ref) => ref.watch(superadminRepositoryProvider).watchStores(),
  retry: (_, _) => null,
);
