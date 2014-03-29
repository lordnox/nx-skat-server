#!/bin/env node

// create a loggin instance
var log = require('debug')('skat-server');
// create the app
var app = require('./application')(log);

// init
app.initialize();
// start
app.start();

// register stop function
var stop = function(sig) {
  return function() {
    app.stop(sig);
    process.exit(1);
  };
};

// Removed 'SIGPIPE' from the list - bugz 852598.
['SIGHUP', 'SIGINT', 'SIGQUIT', 'SIGILL', 'SIGTRAP', 'SIGABRT',
 'SIGBUS', 'SIGFPE', 'SIGUSR1', 'SIGSEGV', 'SIGUSR2', 'SIGTERM'
].forEach(function(element) {
    process.on(element, stop(element));
});

process.on('exit', function() { app.stop(); });