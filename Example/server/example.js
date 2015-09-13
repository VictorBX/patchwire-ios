// MyGameServer.js
var Server = require('patchwire').Server;
var ClientManager = require('patchwire').ClientManager;

var server = new Server();
var gameLobby = new ClientManager();

gameLobby.on('clientAdded', function() {
});

var commandHandlers = {
  register: function(client, data) {
    gameLobby.broadcast('chat', {
        username: data.username,
        message: data.username + ' has joined the game.',
        type: 1
    });
  },
  chat: function(client, data) {
    gameLobby.broadcast('chat', {
        username: data.username,
        message: data.message,
        type: 0
    });
  },
  logout: function(client, data) {
    gameLobby.broadcast('chat', {
        username: data.username,
        message: data.username + ' has left the game.',
        type: 2
    });
  }
};

gameLobby.addCommandListener('register', commandHandlers.register);
gameLobby.addCommandListener('chat', commandHandlers.chat);
gameLobby.addCommandListener('logout', commandHandlers.logout);

var server = new Server(function(client) {
  gameLobby.addClient(client);
});

server.listen(3001);
