# Atmosphere.Client
#
# This class is responsible for socket communication through messages, thus
# the name, "Message" client.
# -----------------------------------------------------------------------------

class MessageClient
  constructor: (sync) ->
    @sync = sync

  connect: (callback) ->
    @close()
    console.log "[Atmosphere.Client] Connecting to #{@url}"
    @socket = SocketIO.connect(@url, 'force new connection': true)
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
    @sync.updateOrCreate(data.uri, data.attrs)

module.exports = MessageClient