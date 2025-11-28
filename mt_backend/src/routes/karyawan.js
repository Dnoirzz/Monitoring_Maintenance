const express = require('express');
const bcrypt = require('bcrypt');
const { supabase } = require('../config/database');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/karyawan - List all karyawan
router.get('/', verifyToken, async (req, res) => {
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

// POST /api/karyawan - Create karyawan
router.post('/', verifyToken, async (req, res) => {
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

// PUT /api/karyawan/:id - Update karyawan
router.put('/:id', verifyToken, async (req, res) => {
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

// DELETE /api/karyawan/:id - Delete karyawan
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase.from('karyawan').delete().eq('id', id);

    if (error) throw error;
    res.json({ message: 'Karyawan deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting karyawan', error: error.message });
  }
});

module.exports = router;
