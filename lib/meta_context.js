(function() {
  var Lawnchair, MetaContext;

  Lawnchair = require('lib/lawnchair');

  MetaContext = (function() {

    function MetaContext() {}

    MetaContext.prototype.configure = function() {
      var _this = this;
      console.log("configuring");
      return new Lawnchair({
        db: "atmosphere",
        name: "objects",
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

    return MetaContext;

  })();

  module.exports = MetaContext;

}).call(this);
