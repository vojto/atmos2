Lawnchair = require('./vendor/lawnchair')

# Atmosphere.MetaContext
#
# This class manages "meta" objects. Every application object has a meta object
# where all synchronization-related information is stored.
# -----------------------------------------------------------------------------

class MetaContext
  constructor: ->
    @configure()
    
  configure: ->
    console.log "configuring"
    new Lawnchair {db: "atmosphere", name: "Meta", adapter: window.LawnchairAdapter}, (store) =>
      @store = store
      @store.get 'version', (object) =>
        @version = if object then object.version else 0

  # Finds meta object for specified ATID
  # IDEA: This function could cache successful finds to speed up finding.
  find: (atid, callback) ->
    @store.get atid, (object) ->
      object.atid = object.key if object
      callback(object)

  create: (atid, uri, callback) ->
    object = {key: atid, uri: uri}
    console.log "creating meta object"
    console.log object
    @store.save(object, callback)
    object
  
  # Working with version
  # ---------------------------------------------------------------------------
  
  currentVersion: ->
    @version

  updateVersion: (version) ->
    @version = version if version > @version
    @store.save({key: 'version', version: @version})
  
  # Marking changes
  # ---------------------------------------------------------------------------
  
  # Marks object at URI as changed.
  markURIChanged: (uri) ->
    mark = (object) =>
      object.isChanged = true
      @saveObject(object)
    @objectAtURI uri, (object) =>
      if object then mark(object) else @createObjectAtURI(uri, mark)
        
  objectAtURI: (uri, callback) ->
    key = "#{uri.collection}.#{uri.id}"
    @store.get key, callback
  
  createObjectAtURI: (uri, callback) ->
    key = "#{uri.collection}.#{uri.id}"
    object = {key: key, isChanged: false, isLocalOnly: true}
    @store.save object, callback
  
  saveObject: (object) ->
    @store.save(object)

module.exports = MetaContext