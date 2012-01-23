(function() {
  var Lawnchair, MetaContext;

  Lawnchair = require('./vendor/lawnchair');

  MetaContext = (function() {

    function MetaContext() {
      this.configure();
    }

    MetaContext.prototype.configure = function() {
      var _this = this;
      console.log("configuring");
      return new Lawnchair({
        db: "atmosphere",
        name: "Meta",
        adapter: window.LawnchairAdapter
      }, function(store) {
        _this.store = store;
        return _this.store.get('version', function(object) {
          return _this.version = object ? object.version : 0;
        });
      });
    };

    MetaContext.prototype.find = function(atid, callback) {
      return this.store.get(atid, function(object) {
        if (object) object.atid = object.key;
        return callback(object);
      });
    };

    MetaContext.prototype.create = function(atid, uri, callback) {
      var object;
      object = {
        key: atid,
        uri: uri
      };
      console.log("creating meta object");
      console.log(object);
      this.store.save(object, callback);
      return object;
    };

    MetaContext.prototype.currentVersion = function() {
      return this.version;
    };

    MetaContext.prototype.updateVersion = function(version) {
      if (version > this.version) this.version = version;
      return this.store.save({
        key: 'version',
        version: this.version
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
      return this.store.get(key, callback);
    };

    MetaContext.prototype.createObjectAtURI = function(uri, callback) {
      var key, object;
      key = "" + uri.collection + "." + uri.id;
      object = {
        key: key,
        isChanged: false,
        isLocalOnly: true
      };
      return this.store.save(object, callback);
    };

    MetaContext.prototype.saveObject = function(object) {
      return this.store.save(object);
    };

    return MetaContext;

  })();

  module.exports = MetaContext;

}).call(this);
