require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Supabase Client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// Helper: Generate JWT Token
const generateToken = (userId, email) => {
  return jwt.sign(
    { userId, email },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
};

// ============================================
// ENDPOINT: POST /api/auth/login
// ============================================
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validasi input
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email dan password harus diisi'
      });
    }

    console.log(`🔐 Login attempt for: ${email}`);

    // 1. Cari user berdasarkan email di tabel karyawan
    const { data: karyawan, error: karyawanError } = await supabase
      .from('karyawan')
      .select('id, email, password_hash, full_name, is_active')
      .eq('email', email)
      .maybeSingle(); // Gunakan maybeSingle agar tidak error jika tidak ketemu

    if (karyawanError) {
      console.error('❌ Supabase Error:', karyawanError);
      return res.status(500).json({
        message: 'Database error',
        details: karyawanError.message
      });
    }

    if (!karyawan) {
      console.log('❌ User tidak ditemukan (Result kosong)');
      // Debug: Coba list semua user untuk memastikan koneksi benar
      const { data: allUsers } = await supabase.from('karyawan').select('email').limit(5);
      console.log('📋 Users in DB (first 5):', allUsers ? allUsers.map(u => u.email) : 'None');
      
      return res.status(401).json({
        message: 'Email atau password salah'
      });
    }

    // Cek apakah user aktif
    if (!karyawan.is_active) {
      console.log('❌ User tidak aktif');
      return res.status(401).json({
        message: 'Akun Anda tidak aktif. Hubungi administrator.'
      });
    }

    // 2. Verifikasi password
    const isPasswordValid = await bcrypt.compare(password, karyawan.password_hash);
    
    if (!isPasswordValid) {
      console.log('❌ Password salah');
      return res.status(401).json({
        message: 'Email atau password salah'
      });
    }

    console.log('✅ Password valid');

    // 3. Ambil daftar aplikasi yang bisa diakses user (tiket)
    const { data: karyawanAplikasi, error: aplikasiError } = await supabase
      .from('karyawan_aplikasi')
      .select(`
        role,
        aplikasi:aplikasi_id (
          kode_aplikasi
        )
      `)
      .eq('karyawan_id', karyawan.id);

    if (aplikasiError) {
      console.error('❌ Error fetching aplikasi:', aplikasiError);
      return res.status(500).json({
        message: 'Terjadi kesalahan saat mengambil data akses aplikasi'
      });
    }

    // 4. Format available_apps
    const availableApps = (karyawanAplikasi || []).map(ka => ({
      kode_aplikasi: ka.aplikasi.kode_aplikasi,
      role: ka.role
    }));

    console.log('📋 Available apps:', availableApps);

    // 5. Generate JWT token
    const token = generateToken(karyawan.id, karyawan.email);

    // 6. Return response
    const response = {
      user: {
        id: karyawan.id,
        email: karyawan.email,
        full_name: karyawan.full_name || email.split('@')[0]
      },
      token: token,
      available_apps: availableApps
    };

    console.log('✅ Login berhasil untuk:', email);
    
    return res.status(200).json(response);

  } catch (error) {
    console.error('❌ Error di /api/auth/login:', error);
    return res.status(500).json({
      message: 'Terjadi kesalahan server',
      error: error.message
    });
  }
});

// ============================================
// ENDPOINT: GET /api/health (untuk test)
// ============================================
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Backend API is running',
    timestamp: new Date().toISOString()
  });
});

// ============================================
// Root endpoint
// ============================================
app.get('/', (req, res) => {
  res.json({
    message: 'Monitoring Maintenance Backend API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /api/health',
      login: 'POST /api/auth/login'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log('');
  console.log('='.repeat(50));
  console.log('🚀 Server running on http://localhost:' + PORT);
  console.log('='.repeat(50));
  console.log('');
  console.log('📌 Endpoints:');
  console.log('   - GET  / ');
  console.log('   - GET  /api/health');
  console.log('   - POST /api/auth/login');
  console.log('');
  console.log('📊 Database: Supabase Online');
  console.log('   URL:', process.env.SUPABASE_URL);
  console.log('');
  console.log('⌨️  Press Ctrl+C to stop');
  console.log('='.repeat(50));
  console.log('');
});

