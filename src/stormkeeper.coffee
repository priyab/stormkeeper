StormAgent = require 'stormagent'
StormData = StormAgent::StormData

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
        return unless @validate data, schema
        super id, data

#-----------------------------------------------------------------

StormRegistry = StormAgent::StormRegistry

class StormTokenRegistry extends StormRegistry

    constructor: (filename) ->
        super filename

        @on 'load', (key,val) ->
            entry = new StormToken val
            if entry?
                entry.saved = true
                @add key, entry

        @on 'expired', (token) ->
            token.destroy() if token.destroy?

    get: (key) ->
        entry = super key

class StormRulesRegistry extends StormRegistry

    constructor: (filename) ->
        super filename


#-----------------------------------------------------------------

class StormKeeper extends StormAgent

    #Stormkeeper decrements the db entries 'expiry' at every cleanupInterval
    #Cleans up the entries when expiry is 0
    cleanupInterval= (5 * 1000) # 5 seconds

    #Stormkeeper default token expiry value
    tokenMaxDuration = (240 * 1000) # 240 seconds

    tokenschema =
    ruleschema =
        name : "rules"
        type : "object"
        additionalProperties : false
        properties :
            id: {type:"string",required:false}
            name: {type:"string",required:false}
            rules: {type:"array",required:true}
            role: {type:"string",required:true}

    constructor: ->
        super
        @import module

        # private functions
        @log 'stormkeeper constructor called'

        @tokens = new StormTokenRegistry "#{@config.datadir}/tokens.db"
        @rules  = new StormRulesRegistry "#{@config.datadir}/rules.db"

        @on 'issued', (token) =>
            if token?

                unless token.id? # new token generated but not yet saved?
                    tokendb.set( token.id, token.data, =>
                        @emit 'changed'
                    ) unless token.saved
                @tokens[token.id] = token

        @rules.on 'load', (key,val) ->
            @add new StormRule val


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

    # For POST /tokens, POST /rules endpoint
    authorize: (token, callback) ->
        if token? and entry.id


                @checkentryschema type, entry, (error) =>
                    @log "entry:", entry
                    unless error instanceof Error
                        # add entry into stormkeeper db
                        keeperdb = @getRelativeDB type
                        @log "entry.id = #{entry.id}"
                        keeperdb.set entry.id, entry, ->
                            return callback(entry)
                    else
                        @log 'entry check: '+ error
                        callback new Error "#{entry.id} entry not added!"
            else
                callback new Error "Invalid entry!!"

    # To remove entry-id from DB
    revoke: (type, entry, callback) ->
        @log 'StormKeeper in DEL entry'
        keeperdb = @getRelativeDB type
        if entry?
            keeperdb.rm entry.id, =>
                @log "removed entry ID: #{entry.id}"
                callback({result:200})

    checkentryschema: (type, entry, callback) ->
        if type == 'TOKENS'
            entryschema = tokenschema
        if type == 'RULES'
            entryschema = ruleschema
        if entryschema?
            @log 'performing entryschema validation on a new entry posting'
            return new Error "Entry data is missing" unless entry
            result = validate entry, entryschema
            error = new Error("Invalid entry posting!")
            throw error unless result.valid
            callback(result)
        else
            return callback new Error("No valid schema to compare:")

    getRules: (usertype, callback) ->
        rules = {}
        @db.rulesdb.forEach (key,rule) ->
            if usertype?
                for rulekey, rulevalue of rule
                    if rulevalue == usertype
                        return callback [ rule ]
            else
                # if the actual data is at the top
                rules[key] = rule unless key in rules
                # if the actual data is at the bottom
                # rules[key] = rule
        callback (entry for entry of rules)

    # For PUT /tokens, PUT /rules endpoint
    update: (type, entry, callback) ->
        if type? and entry? and entry.id
            @add type, entry, (res) =>
                callback res if callback?
        else
            callback new Error "Could not find ID! #{id}" if callback?

module.exports = StormKeeper
