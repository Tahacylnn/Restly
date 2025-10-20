const { Pool } = require('pg');
const url = process.env.DATABASE_URL;
const pool = new Pool({ connectionString: url });

async function initDb(){
  await pool.query(`CREATE EXTENSION IF NOT EXISTS pgcrypto;`);
  await pool.query(`CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text,
    email text UNIQUE,
    password text
  );`);
  await pool.query(`CREATE TABLE IF NOT EXISTS breaks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES users(id),
    type text,
    start_at timestamptz,
    end_at timestamptz,
    ended_at timestamptz
  );`);
  const r = await pool.query('SELECT count(*) FROM users');
  if (parseInt(r.rows[0].count) === 0){
    await pool.query("INSERT INTO users (name,email,password) VALUES ($1,$2,$3)",
      ['Demo User','demo@restly.local','demo_password']);
    console.log('Seeded demo user: demo@restly.local / demo_password');
  }
  console.log('DB initialized');
}

function query(text, params){
  return pool.query(text, params);
}

module.exports = { initDb, query };
