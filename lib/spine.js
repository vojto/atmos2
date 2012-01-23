(function() {
  var Atmosphere, Spine,
    __slice = Array.prototype.slice;

  Spine = require('spine');

  Atmosphere = require('./synchronizer');

  require('./lawnchair_spine');

  Spine.Model.Atmosphere = {
    extended: function() {
      var spineSave;
      this.extend(Spine.Model.Lawnchair);
      spineSave = this.prototype["save"];
      return this.prototype["save"] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        spineSave.call.apply(spineSave, [this].concat(__slice.call(args)));
        if ((args[0] != null) && args[0].remote === true) {
          return Atmosphere.instance.markObjectChanged(this);
        }
      };
    },
    sync: function(params) {
      this.fetch();
      return Atmosphere.instance.fetch(this, params);
    }
  };

}).call(this);
