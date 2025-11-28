const express = require('express');
const { supabase } = require('../config/database');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/checksheet
router.get('/', verifyToken, async (req, res) => {
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

// POST /api/checksheet
router.post('/', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase.from('checksheet').insert([req.body]).select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating checksheet', error: error.message });
  }
});

// PUT /api/checksheet/:id
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase.from('checksheet').update(req.body).eq('id', id).select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating checksheet', error: error.message });
  }
});

// DELETE /api/checksheet/:id
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase.from('checksheet').delete().eq('id', id);

    if (error) throw error;
    res.json({ message: 'Checksheet deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting checksheet', error: error.message });
  }
});

module.exports = router;
