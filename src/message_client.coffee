# Atmosphere.Client
#
# This class is responsible for socket communication through messages, thus
# the name, "Message" client.
# -----------------------------------------------------------------------------

class MessageClient
  constructor: (options) ->
    @atmos = options.atmos
    @base  = options.base

  connect: ->
    @close()
    console.log "messages connecting to #{@base}"
    @socket = SocketIO.connect(@base, 'force new connection': true)
    @socket.on 'connect', =>
      console.log 'socket connected'
    @socket.on 'update', @did_update
    @socket.on 'disconnect', @did_close

  close: ->
    @socket.disconnect() if @socket

  did_close: =>
    console.log "messages connection closed"
    @socket = null

  send: (type, content) ->
    @socket.emit(type, content)

  # Messaging interface
  # ---------------------------------------------------------------------------

  did_update: (payload) =>
    @atmos.trigger('update_object', payload)


module.exports = MessageClient