'use strict';

/**
 * Logika murni (tanpa Firebase) untuk peran, akses toko, dan custom claims.
 * Dipisah dari handler agar mudah dites dan dipakai ulang skrip.
 */

const ROLES = ['superadmin', 'admin', 'kasir'];

/** Custom claims dibatasi 1.000 byte; ~30 id toko per admin masih muat. */
const MAX_STORES_PER_USER = 30;
const MAX_CLAIMS_BYTES = 1000;

/**
 * Pertanyaan terbuka PRD: apakah admin boleh menambah kasir sendiri?
 * Default false (hanya superadmin). Ubah ke true bila diputuskan boleh;
 * admin tetap hanya boleh mengelola KASIR di toko yang ia kelola.
 */
const ADMIN_CAN_MANAGE_KASIR = false;

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Memvalidasi input upsertUser.
 * @returns {{ok: true, value: object} | {ok: false, error: string}}
 */
function validateUserInput(input) {
  if (!input || typeof input !== 'object') {
    return { ok: false, error: 'Data pengguna wajib diisi.' };
  }
  const email = typeof input.email === 'string' ? input.email.trim().toLowerCase() : '';
  if (!EMAIL_PATTERN.test(email)) {
    return { ok: false, error: 'Email tidak valid.' };
  }
  const name = typeof input.name === 'string' ? input.name.trim() : '';
  if (!name) {
    return { ok: false, error: 'Nama wajib diisi.' };
  }
  if (!ROLES.includes(input.role)) {
    return { ok: false, error: 'Peran harus superadmin, admin, atau kasir.' };
  }
  const storeIds = input.storeIds === undefined ? [] : input.storeIds;
  if (!Array.isArray(storeIds) || storeIds.some((id) => typeof id !== 'string' || !id)) {
    return { ok: false, error: 'Daftar toko tidak valid.' };
  }
  if (new Set(storeIds).size !== storeIds.length) {
    return { ok: false, error: 'Daftar toko tidak boleh berisi duplikat.' };
  }
  if (input.role === 'superadmin' && storeIds.length !== 0) {
    return { ok: false, error: 'Superadmin tidak terikat ke toko.' };
  }
  if (input.role === 'kasir' && storeIds.length !== 1) {
    return { ok: false, error: 'Kasir harus terikat ke tepat satu toko.' };
  }
  if (input.role === 'admin' && (storeIds.length < 1 || storeIds.length > MAX_STORES_PER_USER)) {
    return {
      ok: false,
      error: `Admin harus mengelola 1 sampai ${MAX_STORES_PER_USER} toko.`,
    };
  }
  if (input.password !== undefined && input.password !== null) {
    if (typeof input.password !== 'string' || input.password.length < 8) {
      return { ok: false, error: 'Password minimal 8 karakter.' };
    }
  }
  return {
    ok: true,
    value: {
      uid: typeof input.uid === 'string' && input.uid ? input.uid : undefined,
      email,
      name,
      role: input.role,
      storeIds,
      password: input.password || undefined,
      isActive: input.isActive === undefined ? true : input.isActive === true,
    },
  };
}

/**
 * Menurunkan custom claims dari dokumen user dan toko yang aktif.
 * - user nonaktif / peran tak dikenal -> {} (claims dicabut)
 * - superadmin -> {role, storeIds: []}
 * - lainnya -> {role, storeIds: hanya toko yang aktif}
 * @param {{role?: string, storeIds?: string[], isActive?: boolean}|undefined} user
 * @param {Set<string>} activeStoreIds
 */
function computeClaims(user, activeStoreIds) {
  if (!user || user.isActive === false || !ROLES.includes(user.role)) return {};
  if (user.role === 'superadmin') return { role: 'superadmin', storeIds: [] };
  const storeIds = (user.storeIds || []).filter((id) => activeStoreIds.has(id));
  return { role: user.role, storeIds };
}

/** Melempar bila claims melebihi batas ukuran Firebase. */
function assertClaimsSize(claims) {
  const bytes = Buffer.byteLength(JSON.stringify(claims), 'utf8');
  if (bytes > MAX_CLAIMS_BYTES) {
    throw new Error(`Custom claims ${bytes} byte melebihi batas ${MAX_CLAIMS_BYTES}.`);
  }
}

/**
 * Apakah [caller] (claims pemanggil) boleh mengelola [target] ({role, storeIds})?
 * Superadmin: ya. Admin: hanya bila ADMIN_CAN_MANAGE_KASIR dan target kasir di
 * toko yang ia kelola. Lainnya: tidak.
 */
function canManage(caller, target, options = {}) {
  const adminCanManageKasir = options.adminCanManageKasir ?? ADMIN_CAN_MANAGE_KASIR;
  if (!caller) return false;
  if (caller.role === 'superadmin') return true;
  if (caller.role === 'admin' && adminCanManageKasir) {
    const own = new Set(caller.storeIds || []);
    return (
      target.role === 'kasir' &&
      target.storeIds.length > 0 &&
      target.storeIds.every((id) => own.has(id))
    );
  }
  return false;
}

module.exports = {
  ADMIN_CAN_MANAGE_KASIR,
  MAX_CLAIMS_BYTES,
  MAX_STORES_PER_USER,
  ROLES,
  assertClaimsSize,
  canManage,
  computeClaims,
  validateUserInput,
};
