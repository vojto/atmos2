Spine     = require('spine')
SocketIO  = require('./vendor/socket.io')
window.SocketIO = SocketIO

MessageClient   = require('./message_client')
AppContext      = require('./app_context')
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

  constructor: (options) ->
    @messageClient = new MessageClient(this)
    @appContext = new AppContext()
    @resourceClient = new ResourceClient(sync: this, appContext: @appContext)
    @_needsSync = false
    @_isSyncInProgress = false
    Synchronizer.instance = this
    Synchronizer.res = @resourceClient

  # App objects
  updateOrCreate: (uri, item) ->
    # Check for ID change
    if item.id && item.id != uri.id
      console.log "changing id #{uri.id} -> #{item.id}"
      @appContext.changeID(uri, item.id)
      uri.id = item.id
    @appContext.updateOrCreate(uri, item)

  # Resource interface
  # ---------------------------------------------------------------------------

  fetch: (params...) ->
    @resourceClient.fetch(params...)

  save: (object, options) ->
    object.save() # TODO: This is done in atmos-spine bridge
    @resourceClient.save(object, options)

  execute: (params...) -> @resourceClient.execute(params...)
  request: (params...) -> @resourceClient.request(params...)

  # Synchronization
  # ---------------------------------------------------------------------------

  # TODO: Think about how this will be used in the future
  removeObjectsNotInList: (collection, ids, scope) ->
    uris = @appContext.allURIs(collection, scope)
    for uri in uris
      isInList = ids.indexOf(uri.id) != -1
      if !isInList
        @appContext.destroy(uri)

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