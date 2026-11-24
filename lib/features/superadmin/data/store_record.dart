enum UserRole {
  admin('Admin'),
  kasir('Kasir');

  const UserRole(this.label);

  final String label;
}

class StoreUser {
  const StoreUser({
    required this.initials,
    required this.name,
    required this.note,
    required this.role,
  });

  final String initials;
  final String name;
  final String note;
  final UserRole role;
}

/// Toko di sisi superadmin. DATA CONTOH, bukan data sungguhan.
class StoreRecord {
  const StoreRecord({
    required this.code,
    required this.name,
    required this.area,
    required this.admin,
    required this.users,
    required this.createdLabel,
    this.active = true,
    this.scanEnabled = true,
    this.transactionsThisMonth = 0,
  });

  final String code;
  final String name;
  final String area;
  final String admin;
  final List<StoreUser> users;
  final String createdLabel;
  final bool active;
  final bool scanEnabled;
  final int transactionsThisMonth;

  int get kasirCount => users.where((u) => u.role == UserRole.kasir).length;

  StoreRecord copyWith({bool? active}) => StoreRecord(
    code: code,
    name: name,
    area: area,
    admin: admin,
    users: users,
    createdLabel: createdLabel,
    active: active ?? this.active,
    scanEnabled: scanEnabled,
    transactionsThisMonth: transactionsThisMonth,
  );
}
