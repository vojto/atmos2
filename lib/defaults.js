(function() {
  var Defaults, LawnchairStore, Spine,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Spine = require('spine');

  LawnchairStore = require('./lawnchair_store');

  Defaults = (function(_super) {

    __extends(Defaults, _super);

    function Defaults() {
      Defaults.__super__.constructor.apply(this, arguments);
    }

    Defaults.extend(LawnchairStore);

    Defaults.set = function(key, value) {
      return this.prepareStore('defaults', function(store) {
        return store.save({
          key: key,
          value: value
        });
      });
    };

    Defaults.get = function(key, callback) {
      return this.prepareStore('defaults', function(store) {
        return store.get(key, function(object) {
          return callback(object ? object.value : null);
        });
      });
    };

    return Defaults;

  })(Spine.Module);

  module.exports = Defaults;

}).call(this);
