(function() {
  var Atmosphere, Spine;

  Spine = require('spine');

  Atmosphere = require('lib/atmosphere/synchronizer');

  Spine.Model.Atmosphere = {
    extended: function() {},
    fetchRemote: function(params) {
      return Atmosphere.instance.fetch(this.collection(), params);
    }
  };

}).call(this);
