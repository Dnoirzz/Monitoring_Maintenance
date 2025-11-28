const express = require('express');
const { supabase } = require('../config/database');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/mesin
router.get('/', verifyToken, async (req, res) => {
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

// POST /api/mesin
router.post('/', verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase.from('mesin').insert([req.body]).select();

    if (error) throw error;
    res.status(201).json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error creating mesin', error: error.message });
  }
});

// PUT /api/mesin/:id
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase.from('mesin').update(req.body).eq('id', id).select();

    if (error) throw error;
    res.json(data[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error updating mesin', error: error.message });
  }
});

// DELETE /api/mesin/:id
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase.from('mesin').delete().eq('id', id);

    if (error) throw error;
    res.json({ message: 'Mesin deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting mesin', error: error.message });
  }
});

module.exports = router;
