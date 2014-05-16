argv = require('optimist')
    .usage('Start stormkeeper with a configuration file.\nUsage: $0')
    .demand('c')
    .default('c','/etc/stormstack/stormkeeper.json')
    .alias('c', 'config')
    .describe('c', 'location of stormkeeper configuration file')
    .argv

util=require('util')

util.log "stormkeeper coming up as new storm token collector..."
#check and create the necessary data dirs
fs=require('fs')
config=null

try
    config = JSON.parse fs.readFileSync argv.config
catch error
    util.log error
    util.log "stormkeeper using default storm parameters..."
    # whether error with config parsing or not, we will handle using config
    config=
        port : 8333, #default port
        logfile : "/var/log/stormkeeper.log",
        datadir : "/var/stormkeeper",
        serialKey : "unknown",
finally
    util.log "stormkeeper infused with " + JSON.stringify config

try
    fs.mkdirSync("#{config.datadir}") unless fs.existsSync("#{config.datadir}")
    fs.mkdirSync("#{config.datadir}/db")  unless fs.existsSync("#{config.datadir}/db")
    fs.mkdirSync("#{config.datadir}/certs") unless fs.existsSync("#{config.datadir}/certs")
catch error
    util.log "Error in creating data dirs"


# start the stormkeeper web application
{@app} = require('zappajs') config.port, ->
    @configure =>
      @use 'bodyParser', 'methodOverride', @app.router, 'static'
      @set 'basepath': '/v1.0'

    @configure
      development: => @use errorHandler: {dumpExceptions: on, showStack: on}
      production: => @use 'errorHandler'

    @enable 'serve jquery', 'minify'
    @include './plugin'
