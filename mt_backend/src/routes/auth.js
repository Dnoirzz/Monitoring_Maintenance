const express = require('express');
const bcrypt = require('bcrypt');
const { supabase } = require('../config/database');
const { verifyToken, generateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * POST /api/auth/login (Step 1)
 * Validasi credentials dan return available apps
 */
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email dan password harus diisi',
      });
    }

    console.log(`🔐 Login attempt for: ${email}`);

    // 1. Cari user berdasarkan email
    const { data: karyawan, error: karyawanError } = await supabase
      .from('karyawan')
      .select('id, email, password_hash, full_name, is_active, profile_picture')
      .eq('email', email)
      .maybeSingle();

    if (karyawanError) {
      console.error('❌ Supabase Error:', karyawanError);
      return res.status(500).json({
        success: false,
        message: 'Database error',
      });
    }

    if (!karyawan) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah',
      });
    }

    if (!karyawan.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Akun tidak aktif. Hubungi administrator.',
      });
    }

    // 2. Verifikasi password
    const isPasswordValid = await bcrypt.compare(password, karyawan.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah',
      });
    }

    // 3. Ambil daftar aplikasi yang bisa diakses
    const { data: karyawanAplikasi, error: aplikasiError } = await supabase
      .from('karyawan_aplikasi')
      .select(`
        id,
        role,
        aplikasi:aplikasi_id (
          id,
          nama_aplikasi,
          kode_aplikasi
        )
      `)
      .eq('karyawan_id', karyawan.id);

    if (aplikasiError) {
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat mengambil data akses aplikasi',
      });
    }

    // 4. Format available_apps
    const availableApps = (karyawanAplikasi || []).map((ka) => ({
      karyawan_aplikasi_id: ka.id,
      aplikasi_id: ka.aplikasi.id,
      nama_aplikasi: ka.aplikasi.nama_aplikasi,
      kode_aplikasi: ka.aplikasi.kode_aplikasi,
      role: ka.role,
    }));

    console.log('✅ Login Step 1 berhasil untuk:', email);

    return res.status(200).json({
      success: true,
      karyawan_id: karyawan.id,
      email: karyawan.email,
      full_name: karyawan.full_name || email.split('@')[0],
      available_apps: availableApps,
    });
  } catch (error) {
    console.error('❌ Error di /api/auth/login:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server',
    });
  }
});

/**
 * POST /api/auth/select-app (Step 2)
 * Generate JWT token setelah pilih aplikasi
 */
router.post('/select-app', async (req, res) => {
  try {
    const { karyawan_id, aplikasi_id } = req.body;

    if (!karyawan_id || !aplikasi_id) {
      return res.status(400).json({
        success: false,
        message: 'karyawan_id dan aplikasi_id harus diisi',
      });
    }

    // 1. Verify karyawan exists and is active
    const { data: karyawan, error: karyawanError } = await supabase
      .from('karyawan')
      .select('id, email, full_name, profile_picture, is_active')
      .eq('id', karyawan_id)
      .maybeSingle();

    if (karyawanError || !karyawan) {
      return res.status(400).json({
        success: false,
        message: 'Karyawan tidak ditemukan',
      });
    }

    if (!karyawan.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Akun tidak aktif',
      });
    }

    // 2. Verify access to the selected app
    const { data: karyawanAplikasi, error: accessError } = await supabase
      .from('karyawan_aplikasi')
      .select(`
        id,
        role,
        aplikasi:aplikasi_id (
          id,
          nama_aplikasi,
          kode_aplikasi
        )
      `)
      .eq('karyawan_id', karyawan_id)
      .eq('aplikasi_id', aplikasi_id)
      .maybeSingle();

    if (accessError || !karyawanAplikasi) {
      return res.status(403).json({
        success: false,
        message: 'Tidak memiliki akses ke aplikasi ini',
      });
    }

    // 3. Generate JWT token
    const token = generateToken({
      karyawan_id: karyawan.id,
      karyawan_aplikasi_id: karyawanAplikasi.id,
      email: karyawan.email,
      role: karyawanAplikasi.role,
      aplikasi_kode: karyawanAplikasi.aplikasi.kode_aplikasi,
    });

    console.log('✅ Select app berhasil - token generated');

    return res.status(200).json({
      success: true,
      token: token,
      user: {
        karyawan_id: karyawan.id,
        email: karyawan.email,
        full_name: karyawan.full_name,
        role: karyawanAplikasi.role,
        profile_picture: karyawan.profile_picture || null,
        aplikasi: {
          nama: karyawanAplikasi.aplikasi.nama_aplikasi,
          kode: karyawanAplikasi.aplikasi.kode_aplikasi,
        },
      },
    });
  } catch (error) {
    console.error('❌ Error di /api/auth/select-app:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server',
    });
  }
});

/**
 * GET /api/auth/me (Protected)
 * Get current user profile dari token
 */
router.get('/me', verifyToken, async (req, res) => {
  try {
    const { karyawan_id, karyawan_aplikasi_id, role, aplikasi_kode } = req.user;

    const { data: karyawan, error: karyawanError } = await supabase
      .from('karyawan')
      .select('id, email, full_name, profile_picture')
      .eq('id', karyawan_id)
      .maybeSingle();

    if (karyawanError || !karyawan) {
      return res.status(401).json({
        success: false,
        message: 'User tidak ditemukan',
      });
    }

    const { data: karyawanAplikasi } = await supabase
      .from('karyawan_aplikasi')
      .select(`aplikasi:aplikasi_id (nama_aplikasi, kode_aplikasi)`)
      .eq('id', karyawan_aplikasi_id)
      .maybeSingle();

    return res.status(200).json({
      success: true,
      user: {
        karyawan_id: karyawan.id,
        email: karyawan.email,
        full_name: karyawan.full_name,
        role: role,
        profile_picture: karyawan.profile_picture || null,
        aplikasi: {
          nama: karyawanAplikasi?.aplikasi?.nama_aplikasi || 'Unknown',
          kode: aplikasi_kode,
        },
      },
    });
  } catch (error) {
    console.error('❌ Error di /api/auth/me:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server',
    });
  }
});

module.exports = router;
