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

  # Authentication
  # ---------------------------------------------------------------------------

  did_auth: (content) ->
    @trigger("auth_success")

  did_fail_auth: (content) ->
    @trigger("auth_fail")


# Shortcut methods
# ---------------------------------------------------------------------------

resource_methods = ['fetch', 'save', 'execute', 'request']
for method in resource_methods
  Atmos.prototype[method] = -> @resources[method].apply(@resources, arguments)
  Atmos[method] = -> Atmos.instance.resources[method].apply(Atmos.instance.resources, arguments)

module.exports = Atmos