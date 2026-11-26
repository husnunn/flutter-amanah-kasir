'use strict';

/**
 * Logika murni untuk data toko (tanpa Firebase), dipakai `upsertStore` dan dites
 * terpisah.
 *
 * Kode toko (mis. TK01) muncul di nomor nota `{kodeToko}-{yyyyMMdd}-...` dan harus
 * unik. Firestore tidak bisa menjamin keunikan lewat rules, jadi keunikan dijaga
 * Cloud Function dengan dokumen `store_codes/{kode}` di dalam transaksi.
 */

const CODE_PATTERN = /^[A-Z0-9]{2,8}$/;
const PHONE_PATTERN = /^[0-9+()\-\s]*$/;

const NAME_MIN = 2;
const NAME_MAX = 60;
const ADDRESS_MAX = 120;
const PHONE_MAX = 20;

/** "tk01 " -> "TK01"; bukan string -> "". */
function normalizeCode(value) {
  return typeof value === 'string' ? value.trim().toUpperCase() : '';
}

/**
 * Memvalidasi input upsertStore.
 * @param {object} input
 * @param {{isCreate: boolean}} options kode wajib saat membuat; saat mengubah
 *   boleh kosong (kode tidak bisa diubah, hanya dicocokkan oleh pemanggil).
 * @returns {{ok: true, value: object} | {ok: false, error: string}}
 */
function validateStoreInput(input, { isCreate }) {
  if (!input || typeof input !== 'object') {
    return { ok: false, error: 'Data toko wajib diisi.' };
  }

  const name = typeof input.name === 'string' ? input.name.trim() : '';
  if (name.length < NAME_MIN || name.length > NAME_MAX) {
    return { ok: false, error: `Nama toko ${NAME_MIN}-${NAME_MAX} karakter.` };
  }

  const code = normalizeCode(input.code);
  if (isCreate && !code) {
    return { ok: false, error: 'Kode toko wajib diisi.' };
  }
  if (code && !CODE_PATTERN.test(code)) {
    return { ok: false, error: 'Kode toko 2-8 karakter huruf atau angka, tanpa spasi.' };
  }

  const address = input.address === undefined ? '' : input.address;
  if (typeof address !== 'string' || address.trim().length > ADDRESS_MAX) {
    return { ok: false, error: `Alamat maksimal ${ADDRESS_MAX} karakter.` };
  }

  const phone = input.phone === undefined ? '' : input.phone;
  if (
    typeof phone !== 'string' ||
    phone.trim().length > PHONE_MAX ||
    !PHONE_PATTERN.test(phone)
  ) {
    return { ok: false, error: `Telepon maksimal ${PHONE_MAX} karakter (angka, +, -, spasi).` };
  }

  if (input.scanEnabled !== undefined && typeof input.scanEnabled !== 'boolean') {
    return { ok: false, error: 'Pengaturan scan barcode tidak valid.' };
  }

  return {
    ok: true,
    value: {
      storeId: typeof input.storeId === 'string' && input.storeId ? input.storeId : undefined,
      code: code || undefined,
      name,
      address: address.trim(),
      phone: phone.trim(),
      scanEnabled: input.scanEnabled,
    },
  };
}

module.exports = {
  ADDRESS_MAX,
  CODE_PATTERN,
  NAME_MAX,
  NAME_MIN,
  PHONE_MAX,
  normalizeCode,
  validateStoreInput,
};
