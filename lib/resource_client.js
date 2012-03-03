(function() {
  var ResourceClient, Spine, assert,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Spine = require('spine');

  assert = require('./util').assert;

  ResourceClient = (function() {

    function ResourceClient(options) {
      this._updateFromData = __bind(this._updateFromData, this);      this.sync = options.sync;
      this.appContext = options.appContext;
      this.base = null;
      this.headers = {};
      this.routes = null;
      this.IDField = "id";
      this.dataCoding = "form";
      this.subitems = {};
    }

    ResourceClient.prototype.fetch = function(model, options) {
      var collection, ids, path,
        _this = this;
      if (options == null) options = {};
      console.log("[ResourceClient] Fetching with options", options);
      collection = model.className;
      path = this._findPath(collection, "index", options);
      ids = [];
      return this._request(path, {}, function(result) {
        var items;
        items = _this.itemsFromResult(result);
        if (items == null) {
          console.log("[ResourceClient] Items not found in response", result);
          return;
        }
        console.log("[ResourceClient] Found " + items.length + " items");
        ids = _this.updateFromItems(collection, items, options);
        if (options.remove === true) {
          _this._removeObjectsNotInList(collection, ids, options.removeScope);
        }
        if (options.success) options.success();
        return console.log("[ResourceClient] Finished fetch");
      });
    };

    ResourceClient.prototype.updateFromItems = function(collection, items, options) {
      var ids, item, object, uri, _i, _len;
      ids = [];
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        uri = {
          collection: collection
        };
        object = this.updateFromItem(uri, item, options);
        ids.push(object.id);
      }
      return ids;
    };

    ResourceClient.prototype.updateFromItem = function(uri, item, options) {
      if (options == null) options = {};
      item.id = item[this.IDField];
      assert(item.id, "[ResourceClient] There's no field '" + this.IDField + "' that is configured as IDField in incoming object");
      uri.id || (uri.id = item.id);
      if (options.updateData != null) options.updateData(item);
      if (options.updateFromData != null) {
        return options.updateFromData(uri, item, this._updateFromData);
      } else {
        return this._updateFromData(uri, item);
      }
    };

    ResourceClient.prototype._updateFromData = function(uri, data) {
      var object;
      object = this.sync.updateOrCreate(uri, data);
      this.sync.markURISynced(uri);
      return object;
    };

    ResourceClient.prototype._removeObjectsNotInList = function(collection, ids, scope) {
      return this.sync.removeObjectsNotInList(collection, ids, scope);
    };

    ResourceClient.prototype.itemsFromResult = function(result) {
      return result;
    };

    ResourceClient.prototype.save = function(object, options) {
      var data, path,
        _this = this;
      if (options == null) options = {};
      path = this._findPathForObject(object, options.action, options);
      data = options.data || this.appContext.dataForObject(object);
      if (data[this.IDField] == null) data[this.IDField] = object.id;
      if (options.prepareData != null) data = options.prepareData(data, options);
      return this._request(path, data, function(result) {
        var uri;
        if (options.sync) {
          object.save();
          uri = _this.appContext.objectURI(object);
        }
        return _this.updateFromItem(uri, result, options);
      });
    };

    ResourceClient.prototype.execute = function(options, callback) {
      var path;
      if (typeof options === 'string') {
        path = {
          method: 'get',
          path: options
        };
      } else if (options.collection) {
        path = this._findPath(options.collection, options.action, options);
      } else if (options.object) {
        path = this._findPathForObject(options.object, options.action, options);
      }
      return this._request(path, options.data, callback);
    };

    ResourceClient.prototype._findPathForObject = function(object, action, options) {
      var uri, _base;
      uri = this.appContext.objectURI(object);
      options.pathParams || (options.pathParams = {});
      (_base = options.pathParams).id || (_base.id = uri.id);
      return this._findPath(uri.collection, options.action, options);
    };

    ResourceClient.prototype._findPath = function(collection, action, options) {
      var method, param, path, route, value, _ref, _ref2;
      if (options == null) options = {};
      assert(this.routes[collection], "No route found for " + collection);
      path = this.routes[collection][action];
      assert(path, "No route found for " + collection + "/" + action);
      _ref = path.split(" "), method = _ref[0], path = _ref[1];
      if (options.pathParams != null) {
        _ref2 = options.pathParams;
        for (param in _ref2) {
          value = _ref2[param];
          path = path.replace(":" + param, value);
        }
      }
      route = {
        method: method,
        path: path
      };
      if (options.params != null) route.query = $.param(options.params);
      return route;
    };

    ResourceClient.prototype._request = function(path, data, callback) {
      var proceed,
        _this = this;
      proceed = function() {
        var contentType, error, options, success;
        contentType = "application/x-www-form-urlencoded";
        if (_this.dataCoding === "json") {
          data = JSON.stringify(data);
          contentType = "application/json";
        }
        success = function(result) {
          if (callback) return callback(result);
        };
        error = function(res, err) {
          if (res.status === 401) {
            console.log("failed with error 401 " + err);
            return _this.sync.didFailAuth();
          }
          return console.log("Request failed " + res + " " + err, res, err);
        };
        options = {
          dataType: "json",
          success: success,
          error: error,
          headers: _this.headers,
          contentType: contentType
        };
        if (data != null) options.data = data;
        return _this.ajax(path, options);
      };
      if (this.beforeRequest != null) {
        return this.beforeRequest(proceed);
      } else {
        return proceed();
      }
    };

    ResourceClient.prototype.ajax = function(path, options) {
      var url;
      if (options == null) options = {};
      if (typeof path === 'string') {
        path = {
          path: path
        };
      }
      url = this.base + path.path;
      if (path.query) url += "?" + path.query;
      options.type || (options.type = path.method);
      return $.ajax(url, options);
    };

    ResourceClient.prototype.addHeader = function(header, value) {
      return this.headers[header] = value;
    };

    return ResourceClient;

  })();

  module.exports = ResourceClient;

}).call(this);
