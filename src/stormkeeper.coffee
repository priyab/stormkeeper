StormAgent = require 'stormagent'
StormData = StormAgent.StormData

class StormToken extends StormData

    schema =
        name: "tokens"
        type: "object"
        additionalProperties: false
        properties:
            name:         { type:"string", required:false }
            domainId:     { type:"string", required:true  }
            identityId:   { type:"string", required:true  }
            ruleId:       { type:"string", required:true  }
            validity:     { type:"number", required:true  }
            lastModified: { type:"string", required:false }
            userData:
                type: "array"
                items:
                    type: "object"
                    required: false
                    additionalProperties: true
                    properties:
                        accountId: {type:"string", required:false}
                        userEmail: {type:"string", required:false}

    constructor: (id, data) ->
        super id, data, schema

class StormRule extends StormData

    schema =
        name : "rules"
        type : "object"
        additionalProperties : false
        properties :
            id: {type:"string",required:false}
            name: {type:"string",required:false}
            rules: {type:"array",required:true}
            role: {type:"string",required:true}

    constructor: (id, data) ->
        super id, data, schema

#-----------------------------------------------------------------

StormRegistry = StormAgent.StormRegistry

class StormTokenRegistry extends StormRegistry

    constructor: (filename) ->
        @on 'load', (key,val) ->
            entry = new StormToken key,val
            if entry?
                entry.saved = true
                @add key, entry

        @on 'removed', (token) ->
            token.destroy() if token.destroy?

        super filename

    get: (key) ->
        entry = super key
        return unless entry?
        entry.data.id = entry.id
        entry.data.validity = entry.validity
        entry.data

class StormRulesRegistry extends StormRegistry

    constructor: (filename) ->
        @on 'load', (key,val) ->
            entry = new StormRule key,val
            if entry?
                entry.saved = true
                @add key, entry

        @on 'removed', (rule) ->
            rule.destroy() if rule.destroy?

        super filename

    get: (key) ->
        entry = super key
        return unless entry?
        entry.data.id = entry.id
        entry.data

#-----------------------------------------------------------------

class StormKeeper extends StormAgent

    fs = require 'fs'

    constructor: (config) ->
        super
        @import module

        # private functions
        @log 'stormkeeper constructor called', @config.datadir

        fs.mkdir "#{@config.datadir}", (result) ->

        @tokens = new StormTokenRegistry "#{@config.datadir}/tokens.db"
        @rules  = new StormRulesRegistry "#{@config.datadir}/rules.db"

    status: ->
        state = super
        state.tokens = @tokens.list()
        state.rules  = @rules.list()
        state

    run: (config) ->

        ###
        if config?
            @log 'run called with:', config
            res = validate config, schema
            @log 'run - validation of runtime config:', res
            @config = extend(@config, config) if res.valid
        ###

        # start the parent bolt and agent web api instance...
        super config

        @tokens.expires @config.repeatdelay

        # will we have rules with expiry in the future?
        #@rules.expires @config.repeatdelay

    # adds a new or update entry into tokens/rules registry
    authorize: (object, update) ->
        @log "authorize: ", object
        if object instanceof Error
            throw object
        if object instanceof StormToken
            match = @rules.get object.data.ruleId
            unless match?
                throw new Error 'invalid reference to ruleId!'
            res = @tokens.add object.id, object
        if object instanceof StormRule
            res = @rules.add object.id, object
        res.data.id = res.id
        res.data

    # removes entry from tokens/rules registry
    revoke: (object) ->
        if object?
            if object instanceof StormToken
                @tokens.remove object.id
            if object instanceof StormRule
                @rules.remove object.id

module.exports = StormKeeper
module.exports.StormToken = StormToken
module.exports.StormRule  = StormRule

#-------------------------------------------------------------------------------------------

if require.main is module

    ###
    argv = require('optimist')
        .usage('Start stormkeeper with a configuration file.\nUsage: $0')
        .demand('c')
        .default('c','/etc/stormstack/stormkeeper.json')
        .alias('c', 'config')
        .describe('c', 'location of stormkeeper configuration file')
        .argv

    util=require('util')

    util.log "stormkeeper coming up as new storm token collector..."
    ###

    config = null
    storm = null # override during dev
    agent = new StormKeeper config
    agent.run storm
