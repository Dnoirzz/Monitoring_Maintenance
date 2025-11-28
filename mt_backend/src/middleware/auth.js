const jwt = require('jsonwebtoken');

/**
 * Middleware untuk verifikasi JWT Token
 */
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader?.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token tidak ditemukan',
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
        message: 'Token sudah expired',
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Token tidak valid',
    });
  }
};

/**
 * Generate JWT Token dengan payload
 */
const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
};

module.exports = { verifyToken, generateToken };
