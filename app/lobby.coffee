
{EventEmitter} = require 'events'
moment = require 'moment'

module.exports = (io, log) ->

  lobby   = io.lobby = new EventEmitter()
  sockets = io.sockets

  rooms   = {}
  ensureRoomAndIdExists = (room, id) ->
    rooms[room]     = {} if not rooms.hasOwnProperty room
    rooms[room][id] = {} if not rooms[room].hasOwnProperty id

  getRoomDataForId = (room, id) ->
    ensureRoomAndIdExists room, id
    rooms[room][id]

  setRoomDataForId = (room, id, data) ->
    ensureRoomAndIdExists room, id
    rooms[room][id] =
      data: data
      time: moment()
    lobby.emit('refresh:room', room);
    console.log rooms

  getRoomData = (room) ->
    list = {}
    sockets.clients(room).forEach (client) ->
      {data} = getRoomDataForId room, client.id
      list[client.profile.name] = data or {}
    list

  # register join handler
  lobby.on 'join', (socket, room) ->
    socket.join room
    lobby.emit 'refresh:room', room

  # register leave handler
  lobby.on 'leave', (socket, room) ->
    socket.leave room
    lobby.emit 'refresh:room', room

  # register refresh:socket handler
  lobby.on 'refresh:socket', (socket) ->
    Object.keys(sockets.manager.roomClients[socket.id]).filter((_)->_).forEach (room) ->
      lobby.emit 'refresh:room', room.substr 1

  # register refresh:socket handler
  lobby.on 'refresh:room', (room) ->
    log 'sending room refresh for %s', room
    sockets.in(room).emit 'lobby:list:' + room, getRoomData room


  construct = (socket) ->
    socket.on 'lobby:join' , (room)       -> lobby.emit 'join', socket, room
    socket.on 'lobby:leave', (room)       -> lobby.emit 'leave', socket, room
    socket.on 'lobby:set'  , (paket) ->
      {data, room} = paket
      setRoomDataForId room, socket.id, data

    # register profile change handler
    io.profile.on 'change:' + socket.id, -> lobby.emit 'refresh:socket', socket
    io.profile.on 'init:' + socket.id, -> lobby.emit 'refresh:socket', socket

  destruct = (socket) ->
    socket.on 'disconnect', ->
      Object.keys(sockets.manager.roomClients[socket.id]).filter((_)->_).forEach (room) ->
        lobby.emit 'leave', socket, room

  sockets.on 'connection', (socket) ->
    construct socket
    destruct socket


