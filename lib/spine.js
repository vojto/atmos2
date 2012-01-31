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
      this.prototype["save"] = function() {
        var args, atmos, options;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        atmos = Atmosphere.instance;
        options = args[0];
        if ((atmos != null) && (options != null) && options.remote === true) {
          return atmos.save(this, options);
        } else {
          return spineSave.call.apply(spineSave, [this].concat(__slice.call(args)));
        }
      };
      return this.prototype["changeID"] = function(id) {
        this.destroy();
        this.id = id;
        this.newRecord = true;
        return this.save();
      };
    },
    sync: function(params) {
      var atmos;
      if (params == null) params = {};
      this.fetch();
      atmos = Atmosphere.instance;
      if ((atmos != null) && params.remote === true) {
        return atmos.fetch(this, params);
      }
    }
  };

}).call(this);
