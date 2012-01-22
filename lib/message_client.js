(function() {
  var MessageClient,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  MessageClient = (function() {

    function MessageClient(delegate) {
      this.socketDidMessage = __bind(this.socketDidMessage, this);
      this.socketDidClose = __bind(this.socketDidClose, this);      this.delegate = delegate;
      this.host = "localhost";
      this.port = 4001;
    }

    MessageClient.prototype.connect = function(callback) {
      this.close();
      console.log("[Atmosphere.Client] Opening new connection");
      this.socket = SocketIO.connect("ws://" + this.host + ":" + this.port + "/", {
        'force new connection': true
      });
      this.socket.on('connect', callback);
      this.socket.on('message', this.socketDidMessage);
      return this.socket.on('disconnect', this.socketDidClose);
    };

    MessageClient.prototype.close = function() {
      if (this.socket) return this.socket.disconnect();
    };

    MessageClient.prototype.socketDidClose = function() {
      console.log("[Atmosphere.Client] Connection closed");
      return this.socket = null;
    };

    MessageClient.prototype.socketDidMessage = function(message) {
      var content, type, _ref;
      _ref = JSON.parse(message), type = _ref.type, content = _ref.content;
      return this.delegate.clientDidMessage(type, content);
    };

    MessageClient.prototype.send = function(type, content) {
      var data, message;
      message = {
        type: type,
        content: content
      };
      data = JSON.stringify(message);
      console.log("Sending JSON: " + data);
      return this.socket.send(data);
    };

    MessageClient.prototype.request = function(type, params, callback) {
      return $.get("http://" + this.host + ":" + this.port + "/" + type, params, function(result) {
        return callback(result);
      });
    };

    return MessageClient;

  })();

  module.exports = MessageClient;

}).call(this);
