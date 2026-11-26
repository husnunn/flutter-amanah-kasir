import 'package:amanah_kasir/features/superadmin/data/sample_superadmin_repository.dart';
import 'package:amanah_kasir/features/superadmin/data/superadmin_repository.dart';
import 'package:amanah_kasir/features/superadmin/state/superadmin_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Memasang repositori kelola toko/pengguna palsu (default: data contoh).
List<Override> superadminOverrides([SuperadminRepository? repository]) => [
  superadminRepositoryProvider.overrideWithValue(
    repository ?? SampleSuperadminRepository(),
  ),
];
