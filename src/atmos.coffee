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
    options.atmos = this
    @messages   = new MessageClient(options)
    @resources  = new ResourceClient(options)
    Atmos.instance = this
    Atmos.ready() if Atmos.ready?

  fetch   : (params...) -> @resources.fetch(params...)
  create  : (params...) -> @resources.create(params...)
  update  : (params...) -> @resources.update(params...)
  request : (params...) -> @resources.request(params...)
  get     : (params...) -> @resources.get(params...)
  post    : (params...) -> @resources.post(params...)

  # Events
  # ---------------------------------------------------------------------------

  @bind   : (params...) -> Atmos.instance.bind(params...)
  @trigger: (params...) -> Atmos.instance.bind(params...)

  # Authentication
  # ---------------------------------------------------------------------------

  did_auth: (content) ->
    @trigger("auth_success")

  did_fail_auth: (content) ->
    @trigger("auth_fail")


module.exports = Atmos