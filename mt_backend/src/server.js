require('dotenv').config();
const express = require('express');
const cors = require('cors');

// Import routes
const authRoutes = require('./routes/auth');
const karyawanRoutes = require('./routes/karyawan');
const mesinRoutes = require('./routes/mesin');
const maintenanceRoutes = require('./routes/maintenance');
const checksheetRoutes = require('./routes/checksheet');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/karyawan', karyawanRoutes);
app.use('/api/mesin', mesinRoutes);
app.use('/api/maintenance', maintenanceRoutes);
app.use('/api/checksheet', checksheetRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'MT Backend API is running',
    timestamp: new Date().toISOString(),
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Maintenance Tracking (MT) Backend API',
    version: '2.0.0',
    endpoints: {
      health: 'GET /api/health',
      auth: {
        login: 'POST /api/auth/login (Step 1)',
        selectApp: 'POST /api/auth/select-app (Step 2)',
        me: 'GET /api/auth/me (Protected)',
      },
      karyawan: 'CRUD /api/karyawan',
      mesin: 'CRUD /api/mesin',
      maintenance: 'CRUD /api/maintenance',
      checksheet: 'CRUD /api/checksheet',
    },
  });
});

// Start server
app.listen(PORT, () => {
  console.log('');
  console.log('='.repeat(50));
  console.log(`🚀 MT Backend running on http://localhost:${PORT}`);
  console.log('='.repeat(50));
  console.log('');
  console.log('📌 API Endpoints:');
  console.log('   Auth (2-Step):');
  console.log('   - POST /api/auth/login');
  console.log('   - POST /api/auth/select-app');
  console.log('   - GET  /api/auth/me');
  console.log('');
  console.log('   Resources:');
  console.log('   - /api/karyawan');
  console.log('   - /api/mesin');
  console.log('   - /api/maintenance');
  console.log('   - /api/checksheet');
  console.log('');
  console.log('📊 Database: Supabase');
  console.log('⌨️  Press Ctrl+C to stop');
  console.log('='.repeat(50));
});
