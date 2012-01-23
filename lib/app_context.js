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

    AppContext.prototype.updateOrCreate = function(uri, data) {
      if (this.exists(uri)) {
        return this.update(uri, data);
      } else {
        return this.create(uri, data);
      }
    };

    AppContext.prototype.create = function(uri, data) {
      var model, record;
      model = this._modelForURI(uri);
      console.log("Creating new record for ", uri);
      record = new model(data);
      if (uri.id != null) record.id = uri.id;
      record.save();
      uri.id = record.id;
      return model.fetch();
    };

    AppContext.prototype.update = function(uri, data) {
      var record;
      record = this.objectAtURI(uri);
      record.updateAttributes(data);
      return record.save();
    };

    AppContext.prototype.changeID = function(uri, id) {
      var record;
      record = this.objectAtURI(uri);
      console.log("changing id from " + record.id + " to " + id);
      return record.changeID(id);
    };

    AppContext.prototype.relation = function(name, sourceURI, targetURI) {
      var hash, source, target;
      source = this.objectAtURI(sourceURI);
      target = this.objectAtURI(targetURI);
      hash = {};
      hash[name] = target;
      source.updateAttributes(hash);
      return source.save();
    };

    AppContext.prototype.objectAtURI = function(uri) {
      var model;
      model = this._modelForURI(uri);
      return model.find(uri.id);
    };

    AppContext.prototype.dataForURI = function(uri) {
      return this.objectAtURI(uri).attributes();
    };

    AppContext.prototype._modelForURI = function(uri) {
      var model;
      model = this._models[uri.collection];
      if (!model) {
        console.log("Initializing model", uri.collection);
        model = require("models/" + (uri.collection.underscorize()));
        model.fetch();
        this._models[uri.collection] = model;
      }
      return model;
    };

    AppContext.prototype.objectURI = function(object) {
      return {
        collection: object.constructor.className,
        id: object.id
      };
    };

    return AppContext;

  })();

  module.exports = AppContext;

}).call(this);
