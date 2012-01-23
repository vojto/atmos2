Lawnchair = require('./vendor/lawnchair')

# Atmosphere.MetaContext
#
# This class manages "meta" objects. Every application object has a meta object
# where all synchronization-related information is stored.
# =============================================================================

class MetaContext
  constructor: ->
    @configure()
    
  configure: ->
    # console.log "configuring"
    new Lawnchair {db: "atmosphere", name: "Meta", adapter: window.LawnchairAdapter}, (store) =>
      @store = store
  
  # Marking changes
  # ---------------------------------------------------------------------------
  
  # Marks object at URI as changed.
  markURIChanged: (uri) ->
    # console.log "marking as changed", uri
    mark = (object) =>
      object.isChanged = true
      @saveObject(object)
    @objectAtURI uri, (object) =>
      # console.log "found at uri", uri, object
      if object then mark(object) else @createObjectAtURI(uri, mark)
        
  objectAtURI: (uri, callback) ->
    key = "#{uri.collection}.#{uri.id}"
    @store.get key, (dict) ->
      if dict? then callback(new MetaObject(dict)) else callback(null)
  
  createObjectAtURI: (uri, callback) ->
    key = "#{uri.collection}.#{uri.id}"
    object = {key: key, isChanged: false, isLocalOnly: true}
    @store.save object, ->
      # console.log "creating meta object for", object
      callback(new MetaObject(object))
  
  saveObject: (object) ->
    # console.log "saving", object, object.storeDict()
    @store.save(object.storeDict())
  
  # Getting changed objects
  # ---------------------------------------------------------------------------
  
  changedObjects: (callback) ->
    changed = []
    @store.all (dicts) ->
      for dict in dicts
        object = new MetaObject(dict)
        changed.push(object) # TODO: if
      callback(changed)

# Atmosphere.MetaObject
#
# Represents a meta object.
# =============================================================================  

class MetaObject
  constructor: (attrs) ->
    return null unless attrs.key
    [collection, id] = attrs.key.split(".")
    @uri = {collection: collection, id: id}
    @isChanged = attrs.isChanged
    @isLocalOnly = attrs.isLocalOnly
  
  storeDict: ->
    {key: @storeKey(), isChanged: @isChanged, isLocalOnly: @isLocalOnly}
  
  storeKey: ->
    "#{@uri.collection}.#{@uri.id}"
    

module.exports = MetaContext