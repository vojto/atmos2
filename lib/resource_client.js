(function() {
  var ResourceClient, Spine, assert;

  Spine = require('spine');

  assert = require('./util').assert;

  ResourceClient = (function() {

    function ResourceClient(options) {
      this.sync = options.sync;
      this.appContext = options.appContext;
      this.base = null;
      this.routes = null;
      this.IDField = "id";
    }

    ResourceClient.prototype.fetch = function(model, options) {
      var collection, path,
        _this = this;
      if (options == null) options = {};
      collection = model.className;
      assert(this.routes[collection], "No route found for " + collection);
      path = this.routes[collection].index;
      return this._request(path, options.params, function(result) {
        var id, item, uri, _i, _len, _results;
        console.log("[ResourceClient] Received " + result.length + " objects");
        _results = [];
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          item = result[_i];
          id = item[_this.IDField];
          assert(id, "[ResourceClient] There's no field '" + _this.IDField + "' that is configured as IDField in incoming object");
          uri = {
            collection: collection,
            id: id
          };
          _results.push(_this.appContext.updateOrCreate(uri, item));
        }
        return _results;
      });
    };

    ResourceClient.prototype._request = function(path, params, callback) {
      var error, success, url,
        _this = this;
      url = this.base + path;
      params || (params = {});
      params.auth_key = this.sync.authKey;
      success = function(result) {
        return callback(result);
      };
      error = function(res, err) {
        if (res.status === 401) return _this.sync.didFailAuth();
        return console.log("Fetch failed", res, err);
      };
      return $.ajax(url, {
        data: params,
        dataType: "json",
        success: success,
        error: error
      });
    };

    return ResourceClient;

  })();

  module.exports = ResourceClient;

}).call(this);
