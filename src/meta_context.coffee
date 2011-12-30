Lawnchair = require('./vendor/lawnchair')

# Atmosphere.MetaContext
#
# This class manages "meta" objects. Every application object has a meta object
# where all synchronization-related information is stored.
# -----------------------------------------------------------------------------

class MetaContext
  constructor: ->

  configure: ->
    console.log "configuring"
    new Lawnchair {db: "atmosphere", name: "objects", adapter: window.LawnchairAdapter}, (store) =>
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

module.exports = MetaContext