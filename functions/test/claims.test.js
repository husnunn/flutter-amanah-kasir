'use strict';

const assert = require('node:assert/strict');
const { describe, it } = require('node:test');

const {
  MAX_STORES_PER_USER,
  assertClaimsSize,
  canManage,
  computeClaims,
  validateUserInput,
} = require('../src/claims');

const valid = (overrides = {}) => ({
  email: 'Kasir@Amanah.Test ',
  name: ' Rina ',
  role: 'kasir',
  storeIds: ['tk01'],
  ...overrides,
});

describe('validateUserInput', () => {
  it('menormalkan email dan nama', () => {
    const result = validateUserInput(valid());
    assert.equal(result.ok, true);
    assert.equal(result.value.email, 'kasir@amanah.test');
    assert.equal(result.value.name, 'Rina');
    assert.equal(result.value.isActive, true);
  });

  it('menolak input kosong, email salah, atau nama kosong', () => {
    assert.equal(validateUserInput(null).ok, false);
    assert.equal(validateUserInput(valid({ email: 'bukan-email' })).ok, false);
    assert.equal(validateUserInput(valid({ name: '   ' })).ok, false);
  });

  it('menolak peran tak dikenal', () => {
    assert.equal(validateUserInput(valid({ role: 'owner' })).ok, false);
  });

  it('kasir harus tepat satu toko', () => {
    assert.equal(validateUserInput(valid({ storeIds: [] })).ok, false);
    assert.equal(validateUserInput(valid({ storeIds: ['a', 'b'] })).ok, false);
    assert.equal(validateUserInput(valid({ storeIds: ['a'] })).ok, true);
  });

  it('admin boleh banyak toko tetapi minimal satu dan maksimal 30', () => {
    assert.equal(validateUserInput(valid({ role: 'admin', storeIds: [] })).ok, false);
    assert.equal(validateUserInput(valid({ role: 'admin', storeIds: ['a', 'b', 'c'] })).ok, true);
    const many = Array.from({ length: MAX_STORES_PER_USER + 1 }, (_, i) => `s${i}`);
    assert.equal(validateUserInput(valid({ role: 'admin', storeIds: many })).ok, false);
  });

  it('superadmin tidak terikat toko', () => {
    assert.equal(validateUserInput(valid({ role: 'superadmin', storeIds: [] })).ok, true);
    assert.equal(validateUserInput(valid({ role: 'superadmin', storeIds: ['a'] })).ok, false);
  });

  it('menolak daftar toko duplikat atau tidak valid', () => {
    assert.equal(validateUserInput(valid({ role: 'admin', storeIds: ['a', 'a'] })).ok, false);
    assert.equal(validateUserInput(valid({ storeIds: [1] })).ok, false);
    assert.equal(validateUserInput(valid({ storeIds: 'tk01' })).ok, false);
  });

  it('password opsional tetapi minimal 8 karakter bila diisi', () => {
    assert.equal(validateUserInput(valid()).ok, true);
    assert.equal(validateUserInput(valid({ password: 'pendek' })).ok, false);
    assert.equal(validateUserInput(valid({ password: 'cukup-panjang' })).ok, true);
  });
});

describe('computeClaims', () => {
  const active = new Set(['tk01', 'tk02']);

  it('user nonaktif: claims dicabut', () => {
    assert.deepEqual(computeClaims({ role: 'admin', storeIds: ['tk01'], isActive: false }, active), {});
  });

  it('peran tidak dikenal atau user tidak ada: claims kosong', () => {
    assert.deepEqual(computeClaims({ role: 'x', storeIds: [] }, active), {});
    assert.deepEqual(computeClaims(undefined, active), {});
  });

  it('superadmin: tanpa toko', () => {
    assert.deepEqual(computeClaims({ role: 'superadmin', storeIds: ['tk01'] }, active), {
      role: 'superadmin',
      storeIds: [],
    });
  });

  it('admin: hanya toko yang aktif', () => {
    const claims = computeClaims({ role: 'admin', storeIds: ['tk01', 'tk03', 'tk02'] }, active);
    assert.deepEqual(claims, { role: 'admin', storeIds: ['tk01', 'tk02'] });
  });

  it('kasir di toko nonaktif: storeIds kosong', () => {
    assert.deepEqual(computeClaims({ role: 'kasir', storeIds: ['tk03'] }, active), {
      role: 'kasir',
      storeIds: [],
    });
  });
});

describe('assertClaimsSize', () => {
  it('lolos untuk 30 toko berid pendek', () => {
    const storeIds = Array.from({ length: 30 }, (_, i) => `toko-${String(i).padStart(4, '0')}`);
    assert.doesNotThrow(() => assertClaimsSize({ role: 'admin', storeIds }));
  });

  it('melempar bila melebihi 1.000 byte', () => {
    const storeIds = Array.from({ length: 60 }, (_, i) => `toko-${String(i).padStart(10, '0')}`);
    assert.throws(() => assertClaimsSize({ role: 'admin', storeIds }), /melebihi batas/);
  });
});

describe('canManage', () => {
  const target = { role: 'kasir', storeIds: ['tk01'] };

  it('superadmin boleh mengelola siapa pun', () => {
    assert.equal(canManage({ role: 'superadmin' }, { role: 'admin', storeIds: ['x'] }), true);
  });

  it('kasir dan pemanggil tanpa peran tidak boleh', () => {
    assert.equal(canManage({ role: 'kasir', storeIds: ['tk01'] }, target), false);
    assert.equal(canManage(undefined, target), false);
  });

  it('admin tidak boleh secara default (pertanyaan terbuka PRD)', () => {
    assert.equal(canManage({ role: 'admin', storeIds: ['tk01'] }, target), false);
  });

  it('bila diaktifkan: admin hanya mengelola kasir di tokonya', () => {
    const admin = { role: 'admin', storeIds: ['tk01', 'tk02'] };
    const on = { adminCanManageKasir: true };
    assert.equal(canManage(admin, target, on), true);
    assert.equal(canManage(admin, { role: 'kasir', storeIds: ['tk09'] }, on), false);
    assert.equal(canManage(admin, { role: 'admin', storeIds: ['tk01'] }, on), false);
    assert.equal(canManage(admin, { role: 'superadmin', storeIds: [] }, on), false);
  });
});
