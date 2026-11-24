'use strict';

const { assertClaimsSize, computeClaims } = require('./claims');

/**
 * Menyelaraskan akses Firebase Auth dengan dokumen `users/{uid}` (sumber
 * kebenaran) dan status toko:
 *  - custom claims = computeClaims(user, toko aktif)
 *  - akun Auth dinonaktifkan bila user.isActive === false
 *  - refresh token dicabut bila [revoke] atau user nonaktif, supaya akses lama
 *    berhenti saat token berikutnya diperbarui
 *
 * @param {{auth: import('firebase-admin/auth').Auth,
 *          db: import('firebase-admin/firestore').Firestore}} deps
 * @param {string} uid
 * @param {{revoke?: boolean}} [options]
 * @returns {Promise<object>} claims yang diset
 */
async function syncUserAccess({ auth, db }, uid, options = {}) {
  const snap = await db.doc(`users/${uid}`).get();
  if (!snap.exists) {
    throw new Error(`Dokumen users/${uid} tidak ditemukan.`);
  }
  const user = snap.data();
  const storeIds = user.storeIds || [];

  const active = new Set();
  if (storeIds.length > 0) {
    const stores = await db.getAll(...storeIds.map((id) => db.doc(`stores/${id}`)));
    for (const store of stores) {
      if (store.exists && store.get('isActive') === true) active.add(store.id);
    }
  }

  const claims = computeClaims(user, active);
  assertClaimsSize(claims);
  await auth.setCustomUserClaims(uid, claims);
  await auth.updateUser(uid, { disabled: user.isActive === false });
  if (options.revoke || user.isActive === false) {
    await auth.revokeRefreshTokens(uid);
  }
  return claims;
}

module.exports = { syncUserAccess };
