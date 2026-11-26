import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/firebase/app_env.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'features/superadmin/data/sample_superadmin_repository.dart';
import 'features/superadmin/state/superadmin_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mode galeri (--dart-define=GALLERY=true) tidak memakai Firebase.
  final status = AppEnv.showGallery
      ? FirebaseStatus.skipped
      : await initFirebase();
  runApp(
    ProviderScope(
      overrides: [
        // Galeri tidak memakai Firebase: layar superadmin memakai data contoh.
        if (AppEnv.showGallery)
          superadminRepositoryProvider.overrideWithValue(
            SampleSuperadminRepository(),
          ),
      ],
      child: AmanahKasirApp(firebaseStatus: status),
    ),
  );
}
