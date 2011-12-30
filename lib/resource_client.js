(function() {
  var ResourceClient, Spine, assert;

  Spine = require('spine');

  assert = require('lib/util').assert;

  ResourceClient = (function() {

    function ResourceClient(options) {
      this.sync = options.sync;
      this.appContext = options.appContext;
      this.base = "http://localhost:3000/api";
      this.routes = {
        projects: {
          index: "/projects.json"
        },
        pages: {
          index: '/pages.json'
        }
      };
    }

    ResourceClient.prototype.fetch = function(collection, params) {
      var model, path,
        _this = this;
      if (params == null) params = {};
      model = this.appContext.modelForCollection(collection);
      assert(this.routes[collection], "No route found for " + collection);
      path = this.routes[collection].index;
      return this._request(path, params, function(result) {
        var id, item, uri, _i, _len, _results;
        console.log("[ResourceClient] Received " + result.length + " objects");
        model.fetch();
        _results = [];
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          item = result[_i];
          id = item._id;
          uri = {
            collection: collection,
            id: id
          };
          _results.push(_this.sync.updateObject(uri, item));
        }
        return _results;
      });
    };

    ResourceClient.prototype._request = function(path, params, callback) {
      var error, headers, success, url,
        _this = this;
      url = this.base + path;
      params || (params = {});
      params.auth_key = this.sync.authKey;
      success = function(result) {
        return callback(result);
      };
      error = function(res) {
        if (res.status === 401) return _this.sync.didFailAuth();
      };
      headers = {
        "Atmosphere-Auth-Key": this.sync.authKey
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
