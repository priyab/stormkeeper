argv = require('optimist')
    .usage('Start stormkeeper with a configuration file.\nUsage: $0')
    .demand('c')
    .default('c','/etc/stormstack/stormkeeper.json')
    .alias('c', 'config')
    .describe('c', 'location of stormkeeper configuration file')
    .argv

util=require('util')

util.log "stormkeeper coming up as new storm token collector..."

StormKeeper = require './stormkeeper'
agent = new StormKeeper

# agent.on "running", ->
#     @log "starting activation..."
#     @activate null, (err, status) =>
#         @log "activation completed with:", status

agent.run()
