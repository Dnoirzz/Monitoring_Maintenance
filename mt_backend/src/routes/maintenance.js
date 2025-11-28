const express = require('express');
const { supabase } = require('../config/database');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/maintenance
router.get('/', verifyToken, async (req, res) => {
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

// POST /api/maintenance
router.post('/', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase.from('maintenance').insert([req.body]).select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating maintenance', error: error.message });
  }
});

// PUT /api/maintenance/:id
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase.from('maintenance').update(req.body).eq('id', id).select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating maintenance', error: error.message });
  }
});

// DELETE /api/maintenance/:id
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase.from('maintenance').delete().eq('id', id);

    if (error) throw error;
    res.json({ message: 'Maintenance deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting maintenance', error: error.message });
  }
});

module.exports = router;
