


describe "cardgame", ->

  Cardgame        = require "../app/cardgame"
  {EventEmitter}  = require "events"

  it "should be a module function", ->
    Cardgame.should.be.a.function


