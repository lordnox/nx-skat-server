#!/bin/env node

var util    = require('util');

require('coffee-script/register');


/**
*  Define the  application.
*  This structure is a copy of the sampleApp provided by openshift
*/
var App = function(_log) {
  // make sure this works without "new"
  if(!(this instanceof App))
    return new App(_log);

  //  Scope.
  var self = this;

  var log = function() {
    self.log.push(util.format.apply(null, arguments));
    _log.apply(_log, arguments);
  };


  /*  ================================================================  */
  /*  Helper functions.                                                 */
  /*  ================================================================  */

  /**
  *  Set up server IP address and port # using env variables/defaults.
  */
  self.setupVariables = function() {
    //  Set the environment variables we need.
    self.ipaddress = process.env.OPENSHIFT_NODEJS_IP;
    self.port      = process.env.OPENSHIFT_NODEJS_PORT || 8080;
    self.log       = [];

    if (typeof self.ipaddress === 'undefined') {
      //  Log errors on OpenShift but continue w/ 127.0.0.1 - this
      //  allows us to run/test the app locally.
      log('No OPENSHIFT_NODEJS_IP var, using 127.0.0.1');
      self.ipaddress = '127.0.0.1';
    }
  };

  /**
  *  terminator === the termination handler
  *  Terminate server on receipt of the specified signal.
  *  @param {string} sig  Signal to terminate on.
  */
  self.terminator = function(sig){
    if (typeof sig === 'string') {
      log('%s: Received %s - terminating  app ...',
        Date(Date.now()), sig);
      process.exit(1);
    }
    log('%s: Node server stopped.', Date(Date.now()) );
  };

  /*  ================================================================  */
  /*  App server functions (main app logic here).                       */
  /*  ================================================================  */

  /**
  *  Initialize the server (express) and create the routes and register
  *  the handlers.
  */
  self.initializeServer = function() {
    var application = require('./app');

    self.app    = application.app;
    self.server = application.server;
    self.io     = application.io;

    var app = self.app;

    app.use(function(req, res, next) {
      console.log(req.url);
      next();
    });

    app.engine('jade', require('jade').__express);
    app.set('view engine', 'jade');

    app.get('/', function(req, res) {
      res.render('index', {logs: self.log});
    });
  };


  /**
  *  Initializes the  application.
  */
  self.initialize = function() {
    self.setupVariables();

    // Create the express server and routes.
    self.initializeServer();
  };


  /**
  *  Start the server (starts up the  application).
  */
  self.start = function() {
    //  Start the app on the specific interface (and port).
    self.server.listen(self.port, self.ipaddress, function() {
      log('%s: Node server started on %s:%d ...'
      , Date(Date.now())
      , self.ipaddress
      , self.port
      );
    });
  };

  /**
  *  Stop the server (close the application)
  */
  self.stop = self.terminator;

};


module.exports = App;


