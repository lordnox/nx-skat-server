#!/bin/env node

// create a loggin instance
var log = require('debug')('skat-server');
// create the app
var app = require('./application')(log);

// init
app.initialize();
app.ipaddress = null;
// start
app.start();

// skip the stop-part as it will be terminated through the OS with nodemon