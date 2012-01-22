# Atmosphere.Client
#
# This class is responsible for socket communication through messages, thus
# the name, "Message" client.
# -----------------------------------------------------------------------------

class MessageClient
  constructor: (delegate) ->
    @delegate = delegate
    
    @host = "localhost"
    @port = 4001

  connect: (callback) ->
    @close()
    console.log "[Atmosphere.Client] Opening new connection"
    @socket = SocketIO.connect("ws://#{@host}:#{@port}/", 'force new connection': true)
    @socket.on 'connect', callback
    @socket.on 'message', this.socketDidMessage
    @socket.on 'disconnect', this.socketDidClose

  close: ->
    @socket.disconnect() if @socket

  socketDidClose: =>
    console.log "[Atmosphere.Client] Connection closed"
    @socket = null

  socketDidMessage: (message) =>
    {type, content} = JSON.parse(message)
    @delegate.clientDidMessage type, content

  send: (type, content) ->
    message = {type: type, content: content}
    data = JSON.stringify(message)
    console.log "Sending JSON: #{data}"
    @socket.send(data)
  
  request: (type, params, callback) ->
    $.get "http://#{@host}:#{@port}/#{type}", params, (result) ->
      callback(result)

module.exports = MessageClient