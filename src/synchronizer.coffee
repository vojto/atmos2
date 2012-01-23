Spine     = require('spine')
SocketIO  = require('./vendor/socket.io')
window.SocketIO = SocketIO

MessageClient   = require('./message_client')
AppContext      = require('./app_context')
MetaContext     = require('./meta_context')
ResourceClient  = require('./resource_client')

# Atmosphere.Synchronizer
#
# The main interface used mostly for configuration and management of the
# synchronization.
# -----------------------------------------------------------------------------

class Synchronizer extends Spine.Module
  @include Spine.Events

  # Object lifecycle
  # ---------------------------------------------------------------------------
  
  @instance: ->
    @instance
  
  constructor: (options) ->
    @messageClient = new MessageClient(this)
    @metaContext = new MetaContext()
    @appContext = new AppContext()
    @resourceClient = new ResourceClient(sync: this, appContext: @appContext)
    Synchronizer.instance = this
    @_needsSync = false
    @_isSyncInProgress = false

  # App objects
  updateOrCreate: (uri, item) ->
    # Check for ID change
    if item.id != uri.id
      @appContext.changeID(uri, item.id)
      @metaContext.changeIDAtURI(uri, item.id)
      uri.id = item.id
    @appContext.updateOrCreate(uri, item)

  # Meta objects
  # ---------------------------------------------------------------------------
  
  markObjectChanged: (object) ->
    uri = @appContext.objectURI(object)
    @metaContext.markURIChanged(uri)
    @setNeedsSync()
  
  markURISynced: (uri) ->
    @metaContext.markURISynced(uri)
  
  # Synchronization
  # ---------------------------------------------------------------------------

  setNeedsSync: ->
    @_needsSync = true
    @startSync()
  
  startSync: ->
    return unless @_needsSync == true
    # return if @_isSyncInProgress == true
    @_isSyncInProgress = true
    resourceClient = @resourceClient
    @metaContext.changedObjects (metaObjects) ->
      for metaObject in metaObjects
        action = if metaObject.isLocalOnly then "create" else "update"
        resourceClient.syncURI(metaObject.uri, action)

  # Resource interface
  # ---------------------------------------------------------------------------

  fetch: (params...) ->
    @resourceClient.fetch(params...)
    
  # Auth
  # ---------------------------------------------------------------------------  
  
  setAuthKey: (key) ->
    @authKey = key

  hasAuthKey: ->
    @authKey? && @authKey != ""

  didAuth: (content) ->
    @trigger("auth_success")
    @getChanges()

  didFailAuth: (content) ->
    @trigger("auth_fail")


module.exports = Synchronizer