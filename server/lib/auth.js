const jwt = require('jsonwebtoken');
const secret = process.env.JWT_SECRET || 'dev_secret';
function createToken(payload){
  return jwt.sign(payload, secret, { expiresIn: '12h' });
}
function middleware(req,res,next){
  const h = req.headers.authorization;
  if (!h) return res.status(401).json({error:'noauth'});
  const token = h.replace('Bearer ','');
  try {
    const p = jwt.verify(token, secret);
    req.user = p;
    next();
  } catch(e){
    return res.status(401).json({error:'invalid'});
  }
}
function verify(token){
  return jwt.verify(token, secret);
}
module.exports = { createToken, middleware, verify };
