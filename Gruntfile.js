
module.exports = function(grunt) {

  require("matchdep").filterDev("grunt-*").forEach(grunt.loadNpmTasks);

  grunt.initConfig({
    nodemon: {
      app: {
        script: 'server.js'
      , options: {
          ext: 'js,coffee'
        , env: {
            OPENSHIFT_NODEJS_PORT: 8080
          , DEBUG: 'skat* nx-*'
          }
        }
      }
    }
  });

  grunt.registerTask('default', 'nodemon');
};

