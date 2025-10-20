require('dotenv').config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const { initDb, query } = require('./lib/db');
const auth = require('./lib/auth');
const socketInit = require('./lib/ws');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = process.env.PORT || 3000;

app.post('/auth/login', async (req,res) => {
  const { email, password } = req.body;
  try {
    const row = await query('SELECT * FROM users WHERE email=$1', [email]);
    if (row.rows.length === 0) return res.status(401).json({error:'invalid'});
    const u = row.rows[0];
    const ok = (password === u.password); // demo only! use bcrypt in production
    if (!ok) return res.status(401).json({error:'invalid'});
    const token = auth.createToken({id:u.id, email:u.email});
    return res.json({token, user: {id:u.id, email:u.email, name:u.name}});
  } catch(e){
    console.error(e);
    res.status(500).json({error:'server'});
  }
});

app.get('/user', auth.middleware, async (req,res) => {
  const userId = req.user.id;
  const row = await query('SELECT id,name,email FROM users WHERE id=$1', [userId]);
  res.json(row.rows[0]);
});

app.post('/breaks/start', auth.middleware, async (req,res) => {
  try {
    const { type } = req.body;
    const userId = req.user.id;
    const maxMin = (type==='meal') ? 25 : 10;
    const now = new Date();
    const endAt = new Date(now.getTime() + maxMin*60000);
    const idRes = await query(
      'INSERT INTO breaks (user_id, type, start_at, end_at) VALUES ($1,$2,$3,$4) RETURNING id',
      [userId, type, now.toISOString(), endAt.toISOString()]
    );
    const breakId = idRes.rows[0].id;
    const payload = { type:'lock', breakId, userId, endAt: endAt.toISOString() };
    req.app.get('io').to('user-'+userId).emit('message', payload);
    res.status(201).json({id:breakId, endAt});
  } catch(e){
    console.error(e);
    res.status(500).json({error:'server'});
  }
});

app.post('/breaks/stop', auth.middleware, async (req,res) => {
  try {
    const { id } = req.body;
    const userId = req.user.id;
    await query('UPDATE breaks SET ended_at=$1 WHERE id=$2 AND user_id=$3', [new Date().toISOString(), id, userId]);
    const payload = { type:'unlock', breakId:id, userId };
    req.app.get('io').to('user-'+userId).emit('message', payload);
    res.json({ok:true});
  } catch(e){
    console.error(e);
    res.status(500).json({error:'server'});
  }
});

const server = http.createServer(app);

(async ()=>{
  await initDb();
  const io = socketInit(server);
  app.set('io', io);
  server.listen(PORT, ()=> console.log('Server listening', PORT));
})();
