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
// MIDDLEWARE: Verify JWT Token
// ============================================
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({ message: 'Token tidak ditemukan' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Token tidak valid' });
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

// GET list of checksheet schedules with machine info
app.get('/api/checksheet/schedules', verifyToken, async (req, res) => {
  try {
    const { date, status } = req.query;

    let query = supabase
      .from('cek_sheet_schedule')
      .select(`
        id,
        tgl_jadwal,
        tgl_selesai,
        catatan,
        template:cek_sheet_template!template_id (
          komponen:komponen_assets!komponen_assets_id (
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            )
          )
        )
      `)
      .order('tgl_jadwal', { ascending: false });

    if (date) {
      query = query.eq('tgl_jadwal', date);
    }

    if (status === 'pending') {
      query = query.is('tgl_selesai', null);
    } else if (status === 'completed') {
      query = query.not('tgl_selesai', 'is', null);
    }

    const { data, error } = await query;

    if (error) throw error;

    // Transform data for easier consumption
    const schedules = (data || []).map(schedule => ({
      id: schedule.id,
      date: schedule.tgl_jadwal,
      completed_date: schedule.tgl_selesai,
      status: schedule.tgl_selesai ? 'completed' : 'pending',
      machine_name: schedule.template?.komponen?.asset?.nama_assets || 'Unknown',
      machine_code: schedule.template?.komponen?.asset?.kode_assets || '-',
      notes: schedule.catatan
    }));

    res.json(schedules);
  } catch (error) {
    console.error('Error fetching checksheet schedules:', error);
    res.status(500).json({ message: 'Error fetching checksheet schedules', error: error.message });
  }
});

// GET schedule details with all template items
app.get('/api/checksheet/schedule/:scheduleId', verifyToken, async (req, res) => {
  try {
    const { scheduleId } = req.params;

    // Get schedule with machine info
    const { data: schedule, error: scheduleError } = await supabase
      .from('cek_sheet_schedule')
      .select(`
        id,
        template_id,
        tgl_jadwal,
        tgl_selesai,
        catatan,
        foto_sblm,
        foto_sesudah,
        template:cek_sheet_template!template_id (
          komponen:komponen_assets!komponen_assets_id (
            assets_id,
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            )
          )
        )
      `)
      .eq('id', scheduleId)
      .single();

    if (scheduleError) throw scheduleError;
    if (!schedule) {
      return res.status(404).json({ message: 'Schedule not found' });
    }

    // Get all templates for this asset
    const assetsId = schedule.template?.komponen?.assets_id;

    if (!assetsId) {
      return res.status(400).json({ message: 'Asset information not found' });
    }

    const { data: templates, error: templatesError } = await supabase
      .from('cek_sheet_template')
      .select(`
        id,
        jenis_pekerjaan,
        std_prwtn,
        alat_bahan,
        periode,
        komponen:komponen_assets!komponen_assets_id (
          assets_id
        )
      `)
      .eq('komponen_assets_id', schedule.template.komponen_assets_id);

    if (templatesError) throw templatesError;

    // Get existing results if any
    const { data: existingResults } = await supabase
      .from('cek_sheet_results')
      .select('*')
      .eq('schedule_id', scheduleId);

    // Map results to templates
    const templatesWithResults = (templates || []).map(template => {
      const result = (existingResults || []).find(r => r.template_id === template.id);
      return {
        id: template.id,
        jenis_pekerjaan: template.jenis_pekerjaan,
        std_prwtn: template.std_prwtn,
        alat_bahan: template.alat_bahan || '-',
        status: result?.status || null,
        notes: result?.notes || null,
        photo: result?.photo || null
      };
    });

    const response = {
      schedule: {
        id: schedule.id,
        tgl_jadwal: schedule.tgl_jadwal,
        tgl_selesai: schedule.tgl_selesai,
        catatan: schedule.catatan || '',
        foto_sblm: schedule.foto_sblm,
        foto_sesudah: schedule.foto_sesudah,
        asset_name: schedule.template?.komponen?.asset?.nama_assets || 'Unknown',
        asset_code: schedule.template?.komponen?.asset?.kode_assets || '-'
      },
      templates: templatesWithResults
    };

    res.json(response);
  } catch (error) {
    console.error('Error fetching schedule details:', error);
    res.status(500).json({ message: 'Error fetching schedule details', error: error.message });
  }
});

// POST submit checksheet results
app.post('/api/checksheet/submit', verifyToken, async (req, res) => {
  try {
    const { schedule_id, results, general_notes, foto_sblm, foto_sesudah } = req.body;

    if (!schedule_id || !results || !Array.isArray(results)) {
      return res.status(400).json({ message: 'Invalid request data' });
    }

    // Start transaction-like operations
    // 1. Delete existing results for this schedule
    const { error: deleteError } = await supabase
      .from('cek_sheet_results')
      .delete()
      .eq('schedule_id', schedule_id);

    if (deleteError) throw deleteError;

    // 2. Insert new results
    const resultsToInsert = results.map(result => ({
      schedule_id: schedule_id,
      template_id: result.template_id,
      status: result.status,
      notes: result.notes || null,
      photo: result.photo || null
    }));

    const { error: insertError } = await supabase
      .from('cek_sheet_results')
      .insert(resultsToInsert);

    if (insertError) throw insertError;

    // 3. Update schedule with completion info
    const updateData = {
      tgl_selesai: new Date().toISOString().split('T')[0],
      catatan: general_notes || '',
      completed_by: req.user.userId
    };

    if (foto_sblm) updateData.foto_sblm = foto_sblm;
    if (foto_sesudah) updateData.foto_sesudah = foto_sesudah;

    const { data: updatedSchedule, error: updateError } = await supabase
      .from('cek_sheet_schedule')
      .update(updateData)
      .eq('id', schedule_id)
      .select()
      .single();

    if (updateError) throw updateError;

    res.json({
      message: 'Checksheet submitted successfully',
      schedule: updatedSchedule
    });
  } catch (error) {
    console.error('Error submitting checksheet:', error);
    res.status(500).json({ message: 'Error submitting checksheet', error: error.message });
  }
});

// Legacy endpoints (kept for backward compatibility)
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
    version: '1.0.0',
    endpoints: {
      health: 'GET /api/health',
      auth: {
        login: 'POST /api/auth/login'
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
// Listen di 0.0.0.0 agar bisa diakses dari device lain di network yang sama
app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('='.repeat(50));
  console.log('🚀 Server running on http://0.0.0.0:' + PORT);
  console.log('📱 Untuk akses dari device, gunakan IP komputer Anda');
  console.log('   Contoh: http://192.168.1.100:' + PORT);
  console.log('='.repeat(50));
  console.log('');
  console.log('📌 API Endpoints:');
  console.log('   Auth:');
  console.log('   - POST /api/auth/login');
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

