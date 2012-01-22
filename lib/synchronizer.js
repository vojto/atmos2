(function() {
  var AppContext, MessageClient, MetaContext, ResourceClient, SocketIO, Spine, Synchronizer,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Spine = require('spine');

  SocketIO = require('./vendor/socket.io');

  window.SocketIO = SocketIO;

  MessageClient = require('./message_client');

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
      this.messageClient = new MessageClient(this);
      this.metaContext = new MetaContext();
      this.appContext = new AppContext();
      this.resourceClient = new ResourceClient({
        sync: this,
        appContext: this.appContext
      });
      Synchronizer.instance = this;
    }

    Synchronizer.prototype.markObjectChanged = function(object) {};

    Synchronizer.prototype.fetch = function() {
      var params, _ref;
      params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.resourceClient).fetch.apply(_ref, params);
    };

    return Synchronizer;

  })(Spine.Module);

  module.exports = Synchronizer;

}).call(this);
