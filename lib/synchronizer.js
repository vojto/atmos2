(function() {
  var AppContext, Client, MetaContext, ResourceClient, SocketIO, Spine, Synchronizer,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Spine = require('spine');

  SocketIO = require('./vendor/socket.io');

  window.SocketIO = SocketIO;

  Client = require('./client');

  AppContext = require('./app_context');

  MetaContext = require('./meta_context');

  ResourceClient = require('./resource_client');

  Synchronizer = (function(_super) {

    __extends(Synchronizer, _super);

    Synchronizer.include(Spine.Events);

    Synchronizer.instance = function() {
      return this.instance;
    };

    function Synchronizer(options) {
      this.didPush = __bind(this.didPush, this);      this.client = new Client(this);
      this.metaContext = new MetaContext();
      this.appContext = new AppContext();
      this.resourceClient = new ResourceClient({
        sync: this,
        appContext: this.appContext
      });
      this.authKey = "a0b48ccc3e747caf3ed77d94c8f3efc8b7911019";
      Synchronizer.instance = this;
    }

    Synchronizer.prototype.configure = function() {
      return this.metaContext.configure();
    };

    Synchronizer.prototype.connect = function() {
      var _this = this;
      this.configure();
      console.log("[Atmosphere] Connecting with key " + this.authKey);
      return this.client.connect(function() {
        return _this.client.send("client-connect", {
          auth_key: _this.authKey
        });
      });
    };

    Synchronizer.prototype.clientDidMessage = function(type, content) {
      var handlers;
      handlers = {
        "server-auth-success": this.didAuth,
        "server-auth-failure": this.didFailAuth,
        "server-push": this.didPush
      };
      if (!handlers[type]) {
        return console.log("no handler for message type " + type);
      }
      return handlers[type].call(this, content);
    };

    Synchronizer.prototype.didPush = function(content) {
      return this._applyObjectMessage(content);
    };

    Synchronizer.prototype.setAuthKey = function(key) {
      return this.authKey = key;
    };

    Synchronizer.prototype.hasAuthKey = function() {
      return (this.authKey != null) && this.authKey !== "";
    };

    Synchronizer.prototype.didAuth = function(content) {
      this.trigger("auth_success");
      return this.getChanges();
    };

    Synchronizer.prototype.didFailAuth = function(content) {
      return this.trigger("auth_fail");
    };

    Synchronizer.prototype.getChanges = function() {
      throw "This method is deprecated. Use fetch to fetch whole collection. Change tracking has been dropeed.";
    };

    Synchronizer.prototype.fetch = function() {
      var params, _ref;
      params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.resourceClient).fetch.apply(_ref, params);
    };

    return Synchronizer;

  })(Spine.Module);

  module.exports = Synchronizer;

}).call(this);
