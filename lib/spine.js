(function() {
  var Atmosphere, Spine;

  Spine = require('spine');

  Atmosphere = require('./synchronizer');

  require('./lawnchair_spine');

  Spine.Model.Atmosphere = {
    extended: function() {
      this.extend(Spine.Model.Lawnchair);
      return this.bind('save', function(object) {
        return Atmosphere.instance.markObjectChanged(object);
      });
    },
    sync: function(params) {
      this.fetch();
      return Atmosphere.instance.fetch(this, params);
    }
  };

}).call(this);
