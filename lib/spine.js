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
        var args, options;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        spineSave.call.apply(spineSave, [this].concat(__slice.call(args)));
        options = args[0];
        if ((options != null) && options.remote === true) {
          return Atmosphere.instance.save(this, options);
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
      this.fetch();
      return Atmosphere.instance.fetch(this, params);
    }
  };

}).call(this);
