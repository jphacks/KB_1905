var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
  const io = req.app.locals.io;
  //console.log(io) //io object


  io.sockets.on('connection', function (socket) {
    socket.on('message', function(data) {
      console.log('a'+data);
      socket.emit('Hello');
  });
});
});

module.exports = router;
