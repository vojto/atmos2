(function() {
  var MessageClient,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  MessageClient = (function() {

    function MessageClient(sync) {
      this.parseUpdate = __bind(this.parseUpdate, this);
      this.parseNotification = __bind(this.parseNotification, this);
      this.socketDidClose = __bind(this.socketDidClose, this);      this.sync = sync;
    }

    MessageClient.prototype.connect = function(callback) {
      var _this = this;
      this.close();
      console.log("[Atmosphere.Client] Connecting to " + this.url);
      this.socket = SocketIO.connect(this.url, {
        'force new connection': true
      });
      this.socket.on('connect', function() {
        console.log('socket connected');
        return _this.send('auth', _this.authKey);
      });
      this.socket.on('notification', this.parseNotification);
      this.socket.on('update', this.parseUpdate);
      return this.socket.on('disconnect', this.socketDidClose);
    };

    MessageClient.prototype.close = function() {
      if (this.socket) return this.socket.disconnect();
    };

    MessageClient.prototype.socketDidClose = function() {
      console.log("[Atmosphere.Client] Connection closed");
      return this.socket = null;
    };

    MessageClient.prototype.send = function(type, content) {
      return this.socket.emit(type, content);
    };

    MessageClient.prototype.parseNotification = function(data) {
      return console.log('notification: ', data);
    };

    MessageClient.prototype.parseUpdate = function(data) {
      return this.sync.updateOrCreate(data.uri, data.attrs);
    };

    return MessageClient;

  })();

  module.exports = MessageClient;

}).call(this);
