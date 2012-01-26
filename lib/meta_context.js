(function() {
  var KeyFromURI, Lawnchair, MetaContext, MetaObject, URIFromKey;

  Lawnchair = require('./vendor/lawnchair');

  KeyFromURI = function(uri) {
    return "" + uri.collection + "." + uri.id;
  };

  URIFromKey = function(key) {
    var collection, id, _ref;
    _ref = key.split("."), collection = _ref[0], id = _ref[1];
    return {
      collection: collection,
      id: id
    };
  };

  MetaContext = (function() {

    function MetaContext() {
      this.configure();
    }

    MetaContext.prototype.configure = function() {
      var _this = this;
      return new Lawnchair({
        db: "atmosphere",
        name: "Meta",
        adapter: window.LawnchairAdapter
      }, function(store) {
        return _this.store = store;
      });
    };

    MetaContext.prototype.markURIChanged = function(uri) {
      var _this = this;
      return this.findOrCreateObjectAtURI(uri, function(object) {
        object.isChanged = true;
        return _this.saveObject(object);
      });
    };

    MetaContext.prototype.findOrCreateObjectAtURI = function(uri, callback) {
      var _this = this;
      return this.objectAtURI(uri, function(object) {
        if (object) {
          return callback(object);
        } else {
          return _this.createObjectAtURI(uri, callback);
        }
      });
    };

    MetaContext.prototype.objectAtURI = function(uri, callback) {
      return this.store.get(KeyFromURI(uri), function(dict) {
        if (dict != null) {
          return callback(new MetaObject(dict));
        } else {
          return callback(null);
        }
      });
    };

    MetaContext.prototype.createObjectAtURI = function(uri, callback) {
      var object;
      object = {
        key: KeyFromURI(uri),
        isChanged: false,
        isLocalOnly: true
      };
      return this.store.save(object, function() {
        return callback(new MetaObject(object));
      });
    };

    MetaContext.prototype.saveObject = function(object) {
      return this.store.save(object.storeDict());
    };

    MetaContext.prototype.deleteObject = function(object) {
      return this.store.remove(object.storeKey(), function() {});
    };

    MetaContext.prototype.changeIDAtURI = function(uri, id) {
      var _this = this;
      return this.objectAtURI(uri, function(object) {
        if (!object) return;
        _this.deleteObject(object);
        object.uri.id = id;
        return _this.saveObject(object);
      });
    };

    MetaContext.prototype.isURILocalOnly = function(uri, callback) {
      return this.objectAtURI(uri, function(object) {
        if (!object) return callback(true);
        return callback(object.isLocalOnly);
      });
    };

    MetaContext.prototype.isURIChanged = function(uri, callback) {
      return this.objectAtURI(uri, function(object) {
        if (!object) return callback(false);
        return callback(object.isChanged);
      });
    };

    MetaContext.prototype.changedObjects = function(callback) {
      var changed;
      changed = [];
      return this.store.all(function(dicts) {
        var dict, object, _i, _len;
        for (_i = 0, _len = dicts.length; _i < _len; _i++) {
          dict = dicts[_i];
          object = new MetaObject(dict);
          if (object.isChanged === true) changed.push(object);
        }
        return callback(changed);
      });
    };

    MetaContext.prototype.markURISynced = function(uri) {
      var _this = this;
      return this.findOrCreateObjectAtURI(uri, function(object) {
        object.isLocalOnly = false;
        object.isChanged = false;
        return _this.saveObject(object);
      });
    };

    return MetaContext;

  })();

  MetaObject = (function() {

    function MetaObject(attrs) {
      if (!attrs.key) return null;
      this.uri = URIFromKey(attrs.key);
      this.isChanged = attrs.isChanged;
      this.isLocalOnly = attrs.isLocalOnly;
    }

    MetaObject.prototype.storeDict = function() {
      return {
        key: this.storeKey(),
        isChanged: this.isChanged,
        isLocalOnly: this.isLocalOnly
      };
    };

    MetaObject.prototype.storeKey = function() {
      return KeyFromURI(this.uri);
    };

    return MetaObject;

  })();

  module.exports = MetaContext;

}).call(this);
