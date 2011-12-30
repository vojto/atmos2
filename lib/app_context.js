(function() {
  var AppContext;

  String.prototype.underscorize = function() {
    return this.replace(/([A-Z])/g, function(letter) {
      return ("_" + (letter.toLowerCase())).substr(1);
    });
  };

  AppContext = (function() {

    function AppContext() {
      this._models = {};
    }

    AppContext.prototype.exists = function(uri) {
      var model;
      model = this._modelForURI(uri);
      return !!model.exists(uri.id);
    };

    AppContext.prototype.create = function(uri, data, callback) {
      var model, record;
      model = this._modelForURI(uri);
      record = new model(data);
      if (uri.id != null) record.id = uri.id;
      record.save();
      uri.id = record.id;
      return callback(uri);
    };

    AppContext.prototype.update = function(uri, data) {
      var record;
      record = this._findByURI(uri);
      return record.updateAttributes(data);
    };

    AppContext.prototype.relation = function(name, sourceURI, targetURI) {
      var hash, source, target;
      source = this._findByURI(sourceURI);
      target = this._findByURI(targetURI);
      hash = {};
      hash[name] = target;
      source.updateAttributes(hash);
      return source.save();
    };

    AppContext.prototype._findByURI = function(uri) {
      var model;
      model = this._modelForURI(uri);
      return model.find(uri.id);
    };

    AppContext.prototype._modelForURI = function(uri) {
      var model;
      model = this._models[uri.collection];
      if (!model) {
        model = require("models/" + (uri.collection.underscorize()));
        model.fetch();
        this._models[uri.collection] = model;
      }
      return model;
    };

    return AppContext;

  })();

  module.exports = AppContext;

}).call(this);
