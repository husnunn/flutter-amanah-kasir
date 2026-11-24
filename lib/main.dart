import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/firebase/app_env.dart';
import 'core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mode galeri (--dart-define=GALLERY=true) tidak memakai Firebase.
  final status = AppEnv.showGallery
      ? FirebaseStatus.skipped
      : await initFirebase();
  runApp(ProviderScope(child: AmanahKasirApp(firebaseStatus: status)));
}
