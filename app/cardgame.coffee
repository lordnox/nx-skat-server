
{EventEmitter} = require 'events'

uuid = require 'node-uuid'

ERR_NO_GAME_FOUND = 'ERR_NO_GAME_FOUND'

module.exports =  (io, log) ->

  io.cardgame = new EventEmitter()

  gamesByName = {}
  gamesById   = {}

  class Game
    constructor: (@name, @host) ->
      @id       = uuid()
      @players  = [@host]

      gamesByName[@name] = @
      gamesById[@id] = @

      log 'creating game ' + @name

    view: (player) ->
      console.log @
      @

  Game.findGameByName = (name) -> gamesByName[name]
  Game.findGameById   = (id) -> gamesById[id]

  construct = (socket) ->
    socket.on 'cardgame:create', (name, fn) ->
      game = Game.findGameByName name
      if not game
        game = new Game name, socket.id

      fn game.id

    socket.on 'cardgame:refresh', (id, fn) ->
      console.log 'refresh'
      game = Game.findGameById id
      console.log id, game
      console.log gamesById
      return fn ERR_NO_GAME_FOUND if not game
      fn null, game.view socket.id


  destruct = (socket) -> # nothing to do here

  io.sockets.on 'connection', (socket) ->
    construct socket
    destruct socket
