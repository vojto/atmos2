(function() {
  var Atmosphere, Spine;

  Spine = require('spine');

  Atmosphere = require('./synchronizer');

  require('./lawnchair_spine');

  Spine.Model.Atmosphere = {
    extended: function() {
      return this.extend(Spine.Model.Lawnchair);
    },
    sync: function(params) {
      this.fetch();
      return Atmosphere.instance.fetch(this, params);
    }
  };

}).call(this);
