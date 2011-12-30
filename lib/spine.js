(function() {
  var Atmosphere, Spine;

  Spine = require('spine');

  Atmosphere = require('./synchronizer');

  Spine.Model.Atmosphere = {
    extended: function() {},
    fetchRemote: function(params) {
      return Atmosphere.instance.fetch(this, params);
    }
  };

}).call(this);
