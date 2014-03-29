
{EventEmitter} = require 'events'

module.exports =  (io, log) ->

  io.profile = new EventEmitter()

  construct = (socket) ->
    profile = socket.profile =
      id    : socket.id
      name  : socket.id

    emit = (args...) ->
      args[0] += ':' + socket.id
      io.profile.emit.apply io.profile, args

    set = (key, value) ->
      log 'recieved change'
      profile[key] = value
      emit 'change', key
      console.log profile

    log 'registering handler:...'
    socket.on 'profile:change', (data) -> set data.key, data.value
    socket.on 'profile:refresh', -> socket.emit 'profile:update', profile


    emit 'init'

  destruct = (socket) -> # nothing to do here

  io.sockets.on 'connection', (socket) ->
    construct socket
    destruct socket

