const { Server } = require('socket.io');

module.exports = function(httpServer){
  const io = new Server(httpServer, { cors: { origin: '*' }});
  io.on('connection', (socket) => {
    const token = socket.handshake.query.token;
    try {
      const user = require('./auth').verify(token);
      const uid = user.id;
      socket.join('user-'+uid);
      console.log('agent connected for user', uid);
    } catch(e){
      console.log('ws auth failed', e.message);
      socket.disconnect(true);
    }
    socket.on('message', (m)=> {
      console.log('ws msg', m);
    });
    socket.on('disconnect', ()=> {});
  });
  return io;
};
