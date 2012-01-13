String.prototype.underscorize = ->
	@replace /([A-Z])/g, (letter) -> "_#{letter.toLowerCase()}".substr(1)

class AppContext
  constructor: ->
    @_models = {}
  
  exists: (uri) ->
    model = @_modelForURI(uri)
    !!model.exists(uri.id)
  
  create: (uri, data) ->
    model = @_modelForURI(uri)
    record = new model(data)
    record.id = uri.id if uri.id?
    record.save()
    uri.id = record.id
  
  update: (uri, data) ->
    record = @_findByURI(uri)
    record.updateAttributes(data)
    record.save()
  
  relation: (name, sourceURI, targetURI) ->
    source = @_findByURI(sourceURI)
    target = @_findByURI(targetURI)
    hash = {}
    hash[name] = target
    source.updateAttributes(hash)
    source.save()

  
  _findByURI: (uri) ->
    model = @_modelForURI(uri)
    model.find(uri.id)
  
  _modelForURI: (uri) ->
    model = @_models[uri.collection]
    unless model
      model = require("models/#{uri.collection.underscorize()}")
      model.fetch()
      @_models[uri.collection] = model
    model

module.exports = AppContext