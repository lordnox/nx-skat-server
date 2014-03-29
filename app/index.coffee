
express = require 'express'
debug   = require 'debug'
log_ns  = 'nx-echoserver:'
log     = debug 'nx-echoserver'
http    = require 'http'


app     = express()
server  = http.createServer app

io = require('socket.io').listen server

#io.set 'log level', 2

require('./profile')  io, debug log_ns + 'profile'
require('./lobby')    io, debug log_ns + 'lobby'
require('./cardgame') io, debug log_ns + 'cardgame'

module.exports =
  server: server
  app   : app
  io    : io
