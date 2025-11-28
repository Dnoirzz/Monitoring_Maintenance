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

// Helper: Generate JWT Token for 2-step auth
const generateToken = (payload) => {
  return jwt.sign(
    payload,
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
};

// ============================================
// ENDPOINT: POST /api/auth/login (Step 1)
// Returns available apps without token
// ============================================
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validasi input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email dan password harus diisi'
      });
    }

    console.log(`🔐 Login attempt for: ${email}`);

    // 1. Cari user berdasarkan email di tabel karyawan
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
        details: karyawanError.message
      });
    }

    if (!karyawan) {
      console.log('❌ User tidak ditemukan');
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    // Cek apakah user aktif
    if (!karyawan.is_active) {
      console.log('❌ User tidak aktif');
      return res.status(403).json({
        success: false,
        message: 'Akun tidak aktif. Hubungi administrator.'
      });
    }

    // 2. Verifikasi password
    const isPasswordValid = await bcrypt.compare(password, karyawan.password_hash);
    
    if (!isPasswordValid) {
      console.log('❌ Password salah');
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    console.log('✅ Password valid');

    // 3. Ambil daftar aplikasi yang bisa diakses user dengan detail lengkap
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
      console.error('❌ Error fetching aplikasi:', aplikasiError);
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat mengambil data akses aplikasi'
      });
    }

    // 4. Format available_apps dengan detail lengkap
    const availableApps = (karyawanAplikasi || []).map(ka => ({
      karyawan_aplikasi_id: ka.id,
      aplikasi_id: ka.aplikasi.id,
      nama_aplikasi: ka.aplikasi.nama_aplikasi,
      kode_aplikasi: ka.aplikasi.kode_aplikasi,
      role: ka.role
    }));

    console.log('📋 Available apps:', availableApps);

    // 5. Return response tanpa token (token di-generate di select-app)
    const response = {
      success: true,
      karyawan_id: karyawan.id,
      email: karyawan.email,
      full_name: karyawan.full_name || email.split('@')[0],
      available_apps: availableApps
    };

    console.log('✅ Login Step 1 berhasil untuk:', email);
    
    return res.status(200).json(response);

  } catch (error) {
    console.error('❌ Error di /api/auth/login:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server',
      error: error.message
    });
  }
});

// ============================================
// ENDPOINT: POST /api/auth/select-app (Step 2)
// Generate JWT token after selecting app
// ============================================
app.post('/api/auth/select-app', async (req, res) => {
  try {
    const { karyawan_id, aplikasi_id } = req.body;

    // Validasi input
    if (!karyawan_id || !aplikasi_id) {
      return res.status(400).json({
        success: false,
        message: 'karyawan_id dan aplikasi_id harus diisi'
      });
    }

    console.log(`🔐 Select app attempt - karyawan: ${karyawan_id}, app: ${aplikasi_id}`);

    // 1. Verify karyawan exists and is active
    const { data: karyawan, error: karyawanError } = await supabase
      .from('karyawan')
      .select('id, email, full_name, profile_picture, is_active')
      .eq('id', karyawan_id)
      .maybeSingle();

    if (karyawanError || !karyawan) {
      return res.status(400).json({
        success: false,
        message: 'Karyawan tidak ditemukan'
      });
    }

    if (!karyawan.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Akun tidak aktif'
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

    if (accessError) {
      console.error('❌ Error verifying access:', accessError);
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat verifikasi akses'
      });
    }

    if (!karyawanAplikasi) {
      console.log('❌ Tidak memiliki akses ke aplikasi');
      return res.status(403).json({
        success: false,
        message: 'Tidak memiliki akses ke aplikasi ini'
      });
    }

    // 3. Generate JWT token with app-specific claims
    const tokenPayload = {
      karyawan_id: karyawan.id,
      karyawan_aplikasi_id: karyawanAplikasi.id,
      email: karyawan.email,
      role: karyawanAplikasi.role,
      aplikasi_kode: karyawanAplikasi.aplikasi.kode_aplikasi
    };

    const token = generateToken(tokenPayload);

    // 4. Return response with token and user info
    const response = {
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
          kode: karyawanAplikasi.aplikasi.kode_aplikasi
        }
      }
    };

    console.log('✅ Select app berhasil - token generated');
    
    return res.status(200).json(response);

  } catch (error) {
    console.error('❌ Error di /api/auth/select-app:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server',
      error: error.message
    });
  }
});

// ============================================
// ENDPOINT: GET /api/auth/me (Protected)
// Get current user profile from token
// ============================================
app.get('/api/auth/me', verifyToken, async (req, res) => {
  try {
    const { karyawan_id, karyawan_aplikasi_id, role, aplikasi_kode } = req.user;

    // Get karyawan data
    const { data: karyawan, error: karyawanError } = await supabase
      .from('karyawan')
      .select('id, email, full_name, profile_picture')
      .eq('id', karyawan_id)
      .maybeSingle();

    if (karyawanError || !karyawan) {
      return res.status(401).json({
        success: false,
        message: 'User tidak ditemukan'
      });
    }

    // Get aplikasi name
    const { data: karyawanAplikasi, error: appError } = await supabase
      .from('karyawan_aplikasi')
      .select(`
        aplikasi:aplikasi_id (
          nama_aplikasi,
          kode_aplikasi
        )
      `)
      .eq('id', karyawan_aplikasi_id)
      .maybeSingle();

    const response = {
      success: true,
      user: {
        karyawan_id: karyawan.id,
        email: karyawan.email,
        full_name: karyawan.full_name,
        role: role,
        profile_picture: karyawan.profile_picture || null,
        aplikasi: {
          nama: karyawanAplikasi?.aplikasi?.nama_aplikasi || 'Unknown',
          kode: aplikasi_kode
        }
      }
    };

    return res.status(200).json(response);

  } catch (error) {
    console.error('❌ Error di /api/auth/me:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server'
    });
  }
});

// ============================================
// MIDDLEWARE: Verify JWT Token
// ============================================
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader?.split(' ')[1]; // Bearer <token>
  
  if (!token) {
    return res.status(401).json({ 
      success: false,
      message: 'Token tidak ditemukan' 
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        success: false,
        message: 'Token sudah expired' 
      });
    }
    return res.status(401).json({ 
      success: false,
      message: 'Token tidak valid' 
    });
  }
};

// ============================================
// KARYAWAN ENDPOINTS
// ============================================
app.get('/api/karyawan', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('karyawan')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data || []);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching karyawan', error: error.message });
  }
});

app.post('/api/karyawan', verifyToken, async (req, res) => {
  try {
    const { email, password, full_name, phone, mesin } = req.body;
    const password_hash = await bcrypt.hash(password, 10);

    const { data, error } = await supabase
      .from('karyawan')
      .insert([{ email, password_hash, full_name, phone, mesin, is_active: true }])
      .select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating karyawan', error: error.message });
  }
});

app.put('/api/karyawan/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { email, full_name, phone, mesin, password } = req.body;
    
    const updateData = { email, full_name, phone, mesin };
    if (password) {
      updateData.password_hash = await bcrypt.hash(password, 10);
    }

    const { data, error } = await supabase
      .from('karyawan')
      .update(updateData)
      .eq('id', id)
      .select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating karyawan', error: error.message });
  }
});

app.delete('/api/karyawan/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('karyawan')
      .delete()
      .eq('id', id);

    if (error) throw error;
    res.json({ message: 'Karyawan deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting karyawan', error: error.message });
  }
});

// ============================================
// MESIN ENDPOINTS
// ============================================
app.get('/api/mesin', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('mesin')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data || []);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching mesin', error: error.message });
  }
});

app.post('/api/mesin', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('mesin')
      .insert([req.body])
      .select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating mesin', error: error.message });
  }
});

app.put('/api/mesin/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('mesin')
      .update(req.body)
      .eq('id', id)
      .select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating mesin', error: error.message });
  }
});

app.delete('/api/mesin/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('mesin')
      .delete()
      .eq('id', id);

    if (error) throw error;
    res.json({ message: 'Mesin deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting mesin', error: error.message });
  }
});

// ============================================
// MAINTENANCE ENDPOINTS
// ============================================
app.get('/api/maintenance', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('maintenance')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data || []);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching maintenance', error: error.message });
  }
});

app.post('/api/maintenance', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('maintenance')
      .insert([req.body])
      .select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating maintenance', error: error.message });
  }
});

app.put('/api/maintenance/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('maintenance')
      .update(req.body)
      .eq('id', id)
      .select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating maintenance', error: error.message });
  }
});

app.delete('/api/maintenance/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('maintenance')
      .delete()
      .eq('id', id);

    if (error) throw error;
    res.json({ message: 'Maintenance deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting maintenance', error: error.message });
  }
});

// ============================================
// CHECKSHEET ENDPOINTS
// ============================================
app.get('/api/checksheet', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('checksheet')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data || []);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching checksheet', error: error.message });
  }
});

app.post('/api/checksheet', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('checksheet')
      .insert([req.body])
      .select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating checksheet', error: error.message });
  }
});

app.put('/api/checksheet/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('checksheet')
      .update(req.body)
      .eq('id', id)
      .select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating checksheet', error: error.message });
  }
});

app.delete('/api/checksheet/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('checksheet')
      .delete()
      .eq('id', id);

    if (error) throw error;
    res.json({ message: 'Checksheet deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting checksheet', error: error.message });
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
    version: '2.0.0',
    endpoints: {
      health: 'GET /api/health',
      auth: {
        login: 'POST /api/auth/login (Step 1)',
        selectApp: 'POST /api/auth/select-app (Step 2)',
        me: 'GET /api/auth/me (Protected)'
      },
      karyawan: {
        list: 'GET /api/karyawan',
        create: 'POST /api/karyawan',
        update: 'PUT /api/karyawan/:id',
        delete: 'DELETE /api/karyawan/:id'
      },
      mesin: {
        list: 'GET /api/mesin',
        create: 'POST /api/mesin',
        update: 'PUT /api/mesin/:id',
        delete: 'DELETE /api/mesin/:id'
      },
      maintenance: {
        list: 'GET /api/maintenance',
        create: 'POST /api/maintenance',
        update: 'PUT /api/maintenance/:id',
        delete: 'DELETE /api/maintenance/:id'
      },
      checksheet: {
        list: 'GET /api/checksheet',
        create: 'POST /api/checksheet',
        update: 'PUT /api/checksheet/:id',
        delete: 'DELETE /api/checksheet/:id'
      }
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
  console.log('📌 API Endpoints:');
  console.log('   Auth (2-Step):');
  console.log('   - POST /api/auth/login (Step 1)');
  console.log('   - POST /api/auth/select-app (Step 2)');
  console.log('   - GET  /api/auth/me (Protected)');
  console.log('');
  console.log('   Karyawan:');
  console.log('   - GET    /api/karyawan');
  console.log('   - POST   /api/karyawan');
  console.log('   - PUT    /api/karyawan/:id');
  console.log('   - DELETE /api/karyawan/:id');
  console.log('');
  console.log('   Mesin:');
  console.log('   - GET    /api/mesin');
  console.log('   - POST   /api/mesin');
  console.log('   - PUT    /api/mesin/:id');
  console.log('   - DELETE /api/mesin/:id');
  console.log('');
  console.log('   Maintenance:');
  console.log('   - GET    /api/maintenance');
  console.log('   - POST   /api/maintenance');
  console.log('   - PUT    /api/maintenance/:id');
  console.log('   - DELETE /api/maintenance/:id');
  console.log('');
  console.log('   Checksheet:');
  console.log('   - GET    /api/checksheet');
  console.log('   - POST   /api/checksheet');
  console.log('   - PUT    /api/checksheet/:id');
  console.log('   - DELETE /api/checksheet/:id');
  console.log('');
  console.log('   Utility:');
  console.log('   - GET    /');
  console.log('   - GET    /api/health');
  console.log('');
  console.log('📊 Database: Supabase Online');
  console.log('   URL:', process.env.SUPABASE_URL);
  console.log('');
  console.log('⌨️  Press Ctrl+C to stop');
  console.log('='.repeat(50));
  console.log('');
});

