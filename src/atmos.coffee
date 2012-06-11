Spine     = require('spine')
SocketIO  = require('./vendor/socket.io')
window.SocketIO = SocketIO

MessageClient   = require('./message_client')
ResourceClient  = require('./resource_client')

# Atmosphere.Atmos
#
# The main interface used mostly for configuration and management of the
# synchronization.
# -----------------------------------------------------------------------------

class Atmos extends Spine.Module
  @include Spine.Events

  # Object lifecycle
  # ---------------------------------------------------------------------------

  constructor: (options) ->
    ### Creates an instance of Atmos. ###
    @messages   = new MessageClient(atmos: this)
    @resources  = new ResourceClient(atmos: this)
    Atmos.instance = this


  # Resource interface
  # ---------------------------------------------------------------------------

  fetch: (params...) ->
    @resources.fetch(params...)

  save: (object, options) ->
    @resources.save(object, options)

  # TODO: What's the difference between `execute` and `request`?
  execute: (params...) -> @resources.execute(params...)
  request: (params...) -> @resources.request(params...)

  # Authentication
  # ---------------------------------------------------------------------------

  set_auth_key: (key) ->
    @authKey = key

  has_auth_key: ->
    @authKey? && @authKey != ""

  did_auth: (content) ->
    @trigger("auth_success")

  did_fail_auth: (content) ->
    @trigger("auth_fail")


module.exports = Atmos