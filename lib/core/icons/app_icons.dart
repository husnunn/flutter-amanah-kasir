/// Ikon garis 24x24 (stroke 1.8, ujung membulat) yang dipakai desain.
/// Path diambil dari artboard kanvas UI agar bentuknya identik.
class AppIconData {
  const AppIconData(this.body);

  /// Isi elemen SVG (path/rect/circle) tanpa pembungkus `<svg>`.
  final String body;

  /// SVG lengkap; warna di-override lewat color filter di [AppIcon].
  String svg(double strokeWidth) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#000000" stroke-width="$strokeWidth" stroke-linecap="round" '
      'stroke-linejoin="round">$body</svg>';
}

abstract final class AppIcons {
  static const shoppingBag = AppIconData(
    '<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><path d="M3 6h18M16 10a4 4 0 0 1-8 0"/>',
  );
  static const receipt = AppIconData(
    '<path d="M5 3h14v18l-3-2-2 2-2-2-2 2-2-2-3 2z"/><path d="M9 8h6M9 12h6"/>',
  );
  static const printer = AppIconData(
    '<path d="M6 9V3h12v6"/><rect x="3" y="9" width="18" height="8" rx="2"/><path d="M6 14h12v7H6z"/>',
  );
  static const logOut = AppIconData(
    '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>',
  );
  static const search = AppIconData(
    '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
  );
  static const scan = AppIconData(
    '<path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2M8 8v8M12 8v8M16 8v8"/>',
  );
  static const trash = AppIconData(
    '<path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14"/>',
  );
  static const minus = AppIconData('<path d="M5 12h14"/>');
  static const plus = AppIconData('<path d="M12 5v14M5 12h14"/>');
  static const chevronLeft = AppIconData('<path d="M15 18l-6-6 6-6"/>');
  static const chevronRight = AppIconData('<path d="m9 18 6-6-6-6"/>');
  static const chevronDown = AppIconData('<path d="m6 9 6 6 6-6"/>');
  static const chevronsUpDown = AppIconData(
    '<path d="m7 15 5 5 5-5M7 9l5-5 5 5"/>',
  );
  static const check = AppIconData('<path d="M20 6 9 17l-5-5"/>');
  static const close = AppIconData('<path d="M18 6 6 18M6 6l12 12"/>');
  static const cash = AppIconData(
    '<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="3"/>',
  );
  static const qr = AppIconData(
    '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3h-3zM21 14v.01M17 21h4M21 17v4"/>',
  );
  static const bank = AppIconData(
    '<path d="M3 10h18L12 4zM5 10v8M9 10v8M15 10v8M19 10v8M3 20h18"/>',
  );
  static const send = AppIconData(
    '<path d="M22 2 11 13M22 2l-7 20-4-9-9-4z"/>',
  );
  static const mail = AppIconData(
    '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
  );
  static const lock = AppIconData(
    '<rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
  );
  static const eye = AppIconData(
    '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
  );
  static const eyeOff = AppIconData(
    '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/><path d="M4 4l16 16"/>',
  );
  static const calendar = AppIconData(
    '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
  );
  static const camera = AppIconData(
    '<rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7l2-3h4l2 3"/><circle cx="12" cy="13.5" r="3.5"/>',
  );
  static const store = AppIconData(
    '<path d="M3 9l1.5-5h15L21 9M3 9v11h18V9M3 9h18M9 20v-6h6v6"/>',
  );
  static const alertTriangle = AppIconData(
    '<path d="M12 3 2 21h20z"/><path d="M12 10v5M12 18v.01"/>',
  );
  static const wallet = AppIconData(
    '<rect x="3" y="6" width="18" height="14" rx="2"/><path d="M3 10h18M16 15h2"/>',
  );
  static const dashboard = AppIconData(
    '<rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/>',
  );
  static const package = AppIconData(
    '<path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="m3 8 9 5 9-5M12 13v8"/>',
  );
  static const barChart = AppIconData(
    '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
  );
  static const users = AppIconData(
    '<circle cx="9" cy="8" r="4"/><path d="M2 21a7 7 0 0 1 14 0M16 3.5a4 4 0 0 1 0 9M22 21a7 7 0 0 0-4-6.3"/>',
  );
  static const sliders = AppIconData(
    '<path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12"/><circle cx="16" cy="6" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
  );
  static const user = AppIconData(
    '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
  );
  static const more = AppIconData(
    '<circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/>',
  );
  static const backspace = AppIconData(
    '<path d="M20 5H9l-7 7 7 7h11a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2z"/><path d="m18 9-6 6M12 9l6 6"/>',
  );
  static const copy = AppIconData(
    '<rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>',
  );
}
