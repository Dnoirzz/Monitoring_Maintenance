/**
 * Script untuk generate password hash dengan bcrypt
 * Untuk membuat user baru di database
 * 
 * Usage: node generate-password.js <password>
 * Example: node generate-password.js test123
 */

const bcrypt = require('bcrypt');

// Ambil password dari command line argument
const password = process.argv[2];

if (!password) {
  console.log('');
  console.log('❌ Error: Password tidak diberikan');
  console.log('');
  console.log('Usage: node generate-password.js <password>');
  console.log('Example: node generate-password.js test123');
  console.log('');
  process.exit(1);
}

// Generate hash
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('❌ Error generating hash:', err);
    process.exit(1);
  }
  
  console.log('');
  console.log('✅ Password hash generated successfully!');
  console.log('');
  console.log('Password:', password);
  console.log('Hash:', hash);
  console.log('');
  console.log('Copy hash ini dan gunakan di SQL INSERT untuk kolom password_hash');
  console.log('');
});

