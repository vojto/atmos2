(function() {
  var Lawnchair, MetaContext, MetaObject;

  Lawnchair = require('./vendor/lawnchair');

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
      var mark,
        _this = this;
      mark = function(object) {
        object.isChanged = true;
        return _this.saveObject(object);
      };
      return this.objectAtURI(uri, function(object) {
        if (object) {
          return mark(object);
        } else {
          return _this.createObjectAtURI(uri, mark);
        }
      });
    };

    MetaContext.prototype.objectAtURI = function(uri, callback) {
      var key;
      key = "" + uri.collection + "." + uri.id;
      return this.store.get(key, function(dict) {
        if (dict != null) {
          return callback(new MetaObject(dict));
        } else {
          return callback(null);
        }
      });
    };

    MetaContext.prototype.createObjectAtURI = function(uri, callback) {
      var key, object;
      key = "" + uri.collection + "." + uri.id;
      object = {
        key: key,
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

    MetaContext.prototype.changedObjects = function(callback) {
      var changed;
      changed = [];
      return this.store.all(function(dicts) {
        var dict, object, _i, _len;
        for (_i = 0, _len = dicts.length; _i < _len; _i++) {
          dict = dicts[_i];
          object = new MetaObject(dict);
          changed.push(object);
        }
        return callback(changed);
      });
    };

    return MetaContext;

  })();

  MetaObject = (function() {

    function MetaObject(attrs) {
      var collection, id, _ref;
      if (!attrs.key) return null;
      _ref = attrs.key.split("."), collection = _ref[0], id = _ref[1];
      this.uri = {
        collection: collection,
        id: id
      };
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
      return "" + this.uri.collection + "." + this.uri.id;
    };

    return MetaObject;

  })();

  module.exports = MetaContext;

}).call(this);
