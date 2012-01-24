(function() {
  var ResourceClient, Spine, assert;

  Spine = require('spine');

  assert = require('./util').assert;

  ResourceClient = (function() {

    function ResourceClient(options) {
      this.sync = options.sync;
      this.appContext = options.appContext;
      this.base = null;
      this.headers = {};
      this.routes = null;
      this.IDField = "id";
      this.dataCoding = "form";
    }

    ResourceClient.prototype.fetch = function(model, options) {
      var collection, ids, path,
        _this = this;
      if (options == null) options = {};
      console.log("[ResourceClient] Fetching with options", options);
      collection = model.className;
      path = this._findPath(collection, "index", options.pathParams);
      ids = [];
      return this._request(path, options.params, function(result) {
        var item, items, uri, _i, _len;
        items = _this.itemsFromResult(result);
        if (items == null) {
          console.log("[ResourceClient] Items not found in response", result);
          return;
        }
        console.log("[ResourceClient] Found " + items.length + " items");
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          item.id = item[_this.IDField];
          assert(item.id, "[ResourceClient] There's no field '" + _this.IDField + "' that is configured as IDField in incoming object");
          ids.push(item.id);
          uri = {
            collection: collection,
            id: item.id
          };
          if (options.updateData != null) options.updateData(item);
          _this.sync.updateOrCreate(uri, item);
          _this.sync.markURISynced(uri);
        }
        if (options.remove === true) {
          return _this._removeObjectsNotInList(collection, ids);
        }
      });
    };

    ResourceClient.prototype._removeObjectsNotInList = function(collection, ids) {
      var isInList, uri, uris, _i, _len, _results;
      uris = this.appContext.allURIs(collection);
      _results = [];
      for (_i = 0, _len = uris.length; _i < _len; _i++) {
        uri = uris[_i];
        isInList = ids.indexOf(uri.id) !== -1;
        if (!isInList) {
          console.log("[ResourceClient] Local id " + uri.id + " wasn't retrieved, destroying.");
          _results.push(this.appContext.destroy(uri));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    ResourceClient.prototype.itemsFromResult = function(result) {
      return result;
    };

    ResourceClient.prototype.syncURI = function(uri, action) {
      var data, path,
        _this = this;
      console.log("Syncing object", uri);
      path = this._findPath(uri.collection, action);
      data = this.appContext.dataForURI(uri);
      delete data[this.IDField];
      return this._request(path, data, function(result) {
        result.id = result[_this.IDField];
        assert(result.id, "[ResourceClient] There's no field '" + _this.IDField + "' that is configured as IDField in incoming object");
        _this.sync.updateOrCreate(uri, result);
        return _this.sync.markURISynced(uri);
      });
    };

    ResourceClient.prototype._findPath = function(collection, action, params) {
      var method, param, path, value, _ref;
      if (params == null) params = {};
      console.log("finding path", params);
      assert(this.routes[collection], "No route found for " + collection);
      path = this.routes[collection][action];
      assert(path, "No route found for " + collection + "/" + action);
      _ref = path.split(" "), method = _ref[0], path = _ref[1];
      if (params != null) {
        for (param in params) {
          value = params[param];
          path = path.replace(":" + param, value);
        }
      }
      return {
        method: method,
        path: path
      };
    };

    ResourceClient.prototype._request = function(path, params, callback) {
      var contentType, data, error, method, success, url,
        _this = this;
      url = this.base + path.path;
      method = path.method;
      data = params || {};
      contentType = "application/x-www-form-urlencoded";
      if (this.dataCoding === "json") {
        data = JSON.stringify(data);
        contentType = "application/json";
      }
      success = function(result) {
        return callback(result);
      };
      error = function(res, err) {
        if (res.status === 401) return _this.sync.didFailAuth();
        return console.log("Fetch failed", res, err);
      };
      return $.ajax(url, {
        type: method,
        data: data,
        dataType: "json",
        success: success,
        error: error,
        headers: this.headers,
        contentType: contentType
      });
    };

    ResourceClient.prototype.addHeader = function(header, value) {
      return this.headers[header] = value;
    };

    return ResourceClient;

  })();

  module.exports = ResourceClient;

}).call(this);
