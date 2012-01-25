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
      this._needsSync = false;
      this._isSyncInProgress = false;
    }

    Synchronizer.prototype.updateOrCreate = function(uri, item) {
      console.log("update or create: ", uri, item);
      if (item.id !== uri.id) {
        console.log("changing id " + uri.id + " -> " + item.id);
        this.appContext.changeID(uri, item.id);
        this.metaContext.changeIDAtURI(uri, item.id);
        uri.id = item.id;
      }
      return this.appContext.updateOrCreate(uri, item);
    };

    Synchronizer.prototype.fetch = function() {
      var params, _ref;
      params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.resourceClient).fetch.apply(_ref, params);
    };

    Synchronizer.prototype.save = function(object, options) {
      var uri;
      if (options.sync) {
        uri = this.appContext.objectURI(object);
        return this.resourceClient.save(object, options);
      } else {
        object.save();
        this.markObjectChanged(object);
        return this.setNeedsSync();
      }
    };

    Synchronizer.prototype.markObjectChanged = function(object) {
      var uri;
      uri = this.appContext.objectURI(object);
      return this.metaContext.markURIChanged(uri);
    };

    Synchronizer.prototype.markURISynced = function(uri) {
      return this.metaContext.markURISynced(uri);
    };

    Synchronizer.prototype.setNeedsSync = function() {
      this._needsSync = true;
      return this.startSync();
    };

    Synchronizer.prototype.startSync = function() {
      var resourceClient,
        _this = this;
      if (this._needsSync !== true) return;
      this._isSyncInProgress = true;
      resourceClient = this.resourceClient;
      return this.metaContext.changedObjects(function(metaObjects) {
        var action, metaObject, object, options, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = metaObjects.length; _i < _len; _i++) {
          metaObject = metaObjects[_i];
          action = metaObject.isLocalOnly ? "create" : "update";
          console.log("syncing meta object " + action, metaObject);
          object = _this.appContext.objectAtURI(metaObject.uri);
          options = {
            action: action
          };
          if (object.remoteSaveOptions != null) {
            options = object.remoteSaveOptions(options);
          }
          _results.push(resourceClient.save(object, options));
        }
        return _results;
      });
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

    return Synchronizer;

  })(Spine.Module);

  module.exports = Synchronizer;

}).call(this);
