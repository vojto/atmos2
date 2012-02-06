(function() {
  var Defaults, Spine,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Spine = require('spine');

  Defaults = (function(_super) {

    __extends(Defaults, _super);

    function Defaults() {
      Defaults.__super__.constructor.apply(this, arguments);
    }

    Defaults.extend(Spine.Events);

    Defaults.set = function(name, value) {
      var key, previous;
      key = "Defaults." + name;
      previous = localStorage[key];
      localStorage[key] = value;
      if (previous !== value) this.trigger(name);
      return value;
    };

    Defaults.get = function(key) {
      return localStorage["Defaults." + key];
    };

    return Defaults;

  })(Spine.Module);

  module.exports = Defaults;

  window.Defaults = Defaults;

}).call(this);
