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
    console.log "[Atmosphere.Client] Connecting to #{@base}"
    @socket = SocketIO.connect(@base, 'force new connection': true)
    @socket.on 'connect', =>
      console.log 'socket connected'
      @send 'auth', @authKey
    @socket.on 'notification', this.parseNotification
    @socket.on 'update', this.parseUpdate
    @socket.on 'disconnect', this.socketDidClose

  close: ->
    @socket.disconnect() if @socket

  socketDidClose: =>
    console.log "[Atmosphere.Client] Connection closed"
    @socket = null

  send: (type, content) ->
    @socket.emit(type, content)

  # Messaging interface
  # ---------------------------------------------------------------------------

  parseNotification: (data) =>
    console.log 'notification: ', data

  parseUpdate: (data) =>
    @atmos.updateOrCreate(data.uri, data.attrs)

module.exports = MessageClient