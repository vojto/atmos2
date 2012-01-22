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

  configure: ->
    @metaContext.configure()
    
  # Messaging (socket) interface
  # ---------------------------------------------------------------------------

  connect: ->
    throw "This method is not implemented yet"
    this.configure()
    console.log "[Atmosphere] Connecting with key #{@authKey}"
    @messageClient.connect =>
      @messageClient.send "client-connect", {auth_key: @authKey}

  clientDidMessage: (type, content) ->
    handlers =
      "server-auth-success": this.didAuth
      "server-auth-failure": this.didFailAuth
      "server-push": this.didPush
    return console.log "no handler for message type #{type}" unless handlers[type]
    handlers[type].call(this, content)
  
  didPush: (content) =>
    @_applyObjectMessage(content)

  # Authentication
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

  # Resource interface
  # ---------------------------------------------------------------------------

  getChanges: ->
    throw "This method is deprecated. Use fetch to fetch whole collection. Change tracking has been dropeed."

  fetch: (params...) ->
    @resourceClient.fetch(params...)


  # Working with ojects
  # ---------------------------------------------------------------------------
  
  # _applyObjectMessage: (message) ->
  #   message = this._parseObjectMessage(message)
  #   {version, atid, collection, data, relations} = message
  #   console.log "[server-push]\n\t\tcollection: %s\n\t\tatid: %s\n\t\tversion: %s\n\t\trelations: %i", collection, atid, version, relations.length
  #   
  #   @metaContext.find atid, (object) =>
  #     if object
  #       this._updateObject(object, data)
  #       this._updateRelations(object, relations)
  #     else
  #       this._createObject atid, collection, data, (object) =>
  #         this._updateRelations(object, relations)
  #   
  #   @metaContext.updateVersion(version)
  # 
  # _parseObjectMessage: (data) ->
  #   assert data.object_atid, "expected push message to include atid"
  #   assert data.object_entity, "expected push message to include an entity"
  #   assert data.object_data, "expected push message to include data"
  #   {atid: data.object_atid, collection: data.object_entity, data: data.object_data, relations: data.object_relations, version: data.version}
  # 
  # _updateObject: (meta_object, data) ->
  #   throw "This method is deprecated. Please use updateObject instead"
  
  # _createObject: (atid, collection, data, callback) ->
  #   @appContext.create collection, data, (uri) =>
  #     console.log "new URI: ", uri
  #     @metaContext.create(atid, uri, callback)
  
  # Updates relations.
  #
  # TODO: Fix recovery from unexisting target (by delaying applying)
  # _updateRelations: (source_meta_object, relations) ->
  #   return if relations.length == 0
  #   for {name, target} in relations
  #     @metaContext.find target, (target_meta_object) =>
  #       console.log "<Warn> No meta object #{target} found for relation #{name}" unless target_meta_object
  #       @appContext.relation(name, source_meta_object.uri, target_meta_object.uri)
            
        

    # console.log source_app_object
    # 02 Find the app object for target

module.exports = Synchronizer