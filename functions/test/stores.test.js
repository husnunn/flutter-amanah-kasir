'use strict';

const assert = require('node:assert/strict');
const { describe, it } = require('node:test');

const { normalizeCode, validateStoreInput } = require('../src/stores');

const valid = (overrides = {}) => ({
  code: ' tk09 ',
  name: '  Toko Uji  ',
  address: ' Jl. Uji No. 1 ',
  phone: '0812-3456 7890',
  scanEnabled: true,
  ...overrides,
});

describe('normalizeCode', () => {
  it('huruf besar dan tanpa spasi tepi', () => {
    assert.equal(normalizeCode(' tk01 '), 'TK01');
  });

  it('bukan string menjadi kosong', () => {
    assert.equal(normalizeCode(undefined), '');
    assert.equal(normalizeCode(12), '');
  });
});

describe('validateStoreInput (buat)', () => {
  it('menormalkan semua field', () => {
    const result = validateStoreInput(valid(), { isCreate: true });
    assert.equal(result.ok, true);
    assert.equal(result.value.code, 'TK09');
    assert.equal(result.value.name, 'Toko Uji');
    assert.equal(result.value.address, 'Jl. Uji No. 1');
    assert.equal(result.value.scanEnabled, true);
  });

  it('kode wajib saat membuat', () => {
    assert.equal(validateStoreInput(valid({ code: '' }), { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ code: undefined }), { isCreate: true }).ok, false);
  });

  it('kode harus 2-8 huruf/angka tanpa spasi atau simbol', () => {
    for (const bad of ['A', 'TERLALUPANJANG', 'TK 01', 'TK-01', 'TK_01']) {
      assert.equal(validateStoreInput(valid({ code: bad }), { isCreate: true }).ok, false, bad);
    }
    for (const good of ['AB', 'TK01', 'TOKO0001']) {
      assert.equal(validateStoreInput(valid({ code: good }), { isCreate: true }).ok, true, good);
    }
  });

  it('nama 2-60 karakter', () => {
    assert.equal(validateStoreInput(valid({ name: 'A' }), { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ name: '   ' }), { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ name: 'x'.repeat(61) }), { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ name: 'x'.repeat(60) }), { isCreate: true }).ok, true);
  });

  it('alamat dan telepon opsional tetapi dibatasi', () => {
    const minimal = { code: 'TK01', name: 'Toko' };
    assert.equal(validateStoreInput(minimal, { isCreate: true }).ok, true);
    assert.equal(validateStoreInput(valid({ address: 'x'.repeat(121) }), { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ phone: 'telepon' }), { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ phone: '1'.repeat(21) }), { isCreate: true }).ok, false);
  });

  it('menolak input kosong dan scanEnabled bukan boolean', () => {
    assert.equal(validateStoreInput(null, { isCreate: true }).ok, false);
    assert.equal(validateStoreInput(valid({ scanEnabled: 'ya' }), { isCreate: true }).ok, false);
  });
});

describe('validateStoreInput (ubah)', () => {
  it('kode boleh kosong; storeId diteruskan', () => {
    const result = validateStoreInput(
      { storeId: 'abc', name: 'Nama Baru' },
      { isCreate: false },
    );
    assert.equal(result.ok, true);
    assert.equal(result.value.storeId, 'abc');
    assert.equal(result.value.code, undefined);
    assert.equal(result.value.scanEnabled, undefined);
  });

  it('kode yang diisi tetap harus valid', () => {
    const result = validateStoreInput(
      { storeId: 'abc', name: 'Nama', code: 'bad code' },
      { isCreate: false },
    );
    assert.equal(result.ok, false);
  });
});
