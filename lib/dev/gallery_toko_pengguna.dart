import 'package:material_ui/material_ui.dart';

import '../features/superadmin/data/store_record.dart';
import '../features/superadmin/presentation/toko_pengguna_screen.dart';
import 'sample_store_records.dart';

/// Toko & pengguna untuk galeri UI: data contoh, sakelar hanya mengubah
/// daftar di memori (tanpa Firebase).
class GalleryTokoPengguna extends StatefulWidget {
  const GalleryTokoPengguna({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<GalleryTokoPengguna> createState() => _GalleryTokoPenggunaState();
}

class _GalleryTokoPenggunaState extends State<GalleryTokoPengguna> {
  List<StoreRecord> _stores = sampleStoreRecords;

  Future<void> _setActive(StoreRecord store, bool active) async {
    setState(() {
      _stores = [
        for (final s in _stores)
          s.id == store.id ? s.copyWith(active: active) : s,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return TokoPenggunaScreen(
      stores: _stores,
      onSetActive: _setActive,
      onLogout: widget.onLogout,
    );
  }
}
