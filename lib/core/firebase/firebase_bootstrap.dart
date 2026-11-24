import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import 'app_env.dart';

/// Hasil inisialisasi Firebase saat aplikasi dibuka.
enum FirebaseStatus {
  /// Firebase siap dipakai (project asli atau emulator).
  ready,

  /// `firebase_options.dart` masih placeholder; tampilkan panduan setup.
  notConfigured,

  /// Sengaja tidak diinisialisasi (mode galeri UI).
  skipped,
}

/// `projectId` pada placeholder `firebase_options.dart`.
const String _placeholderProjectId = 'belum-dikonfigurasi';

/// Menginisialisasi Firebase. Mode emulator memakai opsi demo dan mengarahkan
/// Auth, Firestore, dan Functions ke emulator lokal.
Future<FirebaseStatus> initFirebase() async {
  if (AppEnv.useEmulator) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'demo-api-key',
        appId: '1:000000000000:android:0000000000000000',
        messagingSenderId: '000000000000',
        projectId: AppEnv.emulatorProjectId,
      ),
    );
    const host = AppEnv.emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, AppEnv.authEmulatorPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      AppEnv.firestoreEmulatorPort,
    );
    FirebaseFunctions.instanceFor(region: AppEnv.functionsRegion)
        .useFunctionsEmulator(host, AppEnv.functionsEmulatorPort);
    return FirebaseStatus.ready;
  }

  final options = DefaultFirebaseOptions.currentPlatform;
  if (options.projectId == _placeholderProjectId) {
    return FirebaseStatus.notConfigured;
  }
  await Firebase.initializeApp(options: options);
  return FirebaseStatus.ready;
}
