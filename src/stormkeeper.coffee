class StormKeeper

    validate = require('json-schema').validate
    uuid = require('node-uuid')
    util = require('util')

    #Stormkeeper decrements the db entries 'expiry' at every cleanupInterval
    #Cleans up the entries when expiry is 0
    cleanupInterval= (5 * 1000) # 5 seconds

    #Stormkeeper default token expiry value 
    tokenMaxDuration = (240 * 1000) # 240 seconds

    tokenschema =
        name : "tokens"
        type : "object"
        additionalProperties : false
	properties :
	    id: {"type":"string","required":false}
	    name: {"type":"string","required":false}
	    domainId: {"type":"string","required":true}
	    identityId: {"type":"string","required":true}
	    userData:
                type: "array"
                items:
                    type: "object"
                    required: false
                    additionalProperties: true
                    properties:
                        accountId: {"type":"string", "required":false}
                        userEmail: {"type":"string", "required":false}
	    rulesId: {"type":"string","required":true}
	    expiry: {"type":"string","required":true}
	    lastModified: {"type":"string","required":false}

    ruleschema =
        name : "rules"
        type : "object"
        additionalProperties : false
	properties :
	    id: {"type":"string","required":false}
	    name: {"type":"string","required":false}
	    rules: {"type":"string","required":true}
	    role: {"type":"string","required":true}

    constructor : ->
        util.log 'stormkeeper constructor called'
	@db = db = 
	    tokensdb: require('dirty') '/var/stormkeeper/tokens.db'
	    rulesdb: require('dirty') '/var/stormkeeper/rules.db'
	@db.tokensdb.on 'load', ->
	    util.log 'loaded tokens.db'
	    @forEach (key,val) ->
	        util.log 'Tokens found ' + key if val 
	@db.rulesdb.on 'load', ->
	    util.log 'loaded rules.db'
	    @forEach (key,val) ->
	        util.log 'Rules found ' + key if val 

    new: ->
        id = uuid.v4()
        return id

    newEntry: (entry,id) ->
	if id
            entry.id = id
        else
            entry.id = @new() 
        return entry

    getRelativeDB: (type) ->
        util.log 'DB type: ' + type
        keeperDb = ''
        switch (type)
          when "TOKENS"
            keeperDb = db.tokensdb
          when "RULES"
            keeperDb = db.rulesdb
        return keeperDb

    checkentryschema: (type, entry) ->
        if type == 'TOKENS'
            @entryschema = tokenschema
        if type == 'RULES'
            @entryschema = ruleschema
        if entryschema?
	        util.log 'performing entryschema validation on a new entry posting'
	        return new Error "Entry data is missing" unless token
	        result = validate entry, entryschema 
	        error = new Error("Invalid entry posting!")
	        throw error unless result.valid
	        return result

    getEntriesById: (type, id, callback) ->
        util.log "looking up entry ID: #{id}"
        keeperdb = @getRelativeDB type
        entry = @db.keeperdb.get id
        if entry
            result = @checkentryschema type, entry
            util.log result
            return callback new Error "Invalid entry retrieved: #{result.errors}" unless result.valid 
            return callback(entry)
        else
            return callback new Error "Entry not found: #{entry.id}"

    getTokens: ->
  	res = { 'tokens': [] }
	@db.tokensdb.forEach (key,val) ->
	    res.tokens.push val if val
            util.log 'listing...'
	    return res

    getRulesbyRole: (role, callback) ->
        if role
            @db.rulesdb.forEach (key,val) ->
                ruleEntry = db.rulesdb.get key
                for ruleKey, ruleValue of ruleEntry
                    if ruleKey == role
                        util.log 'Entry #{entry.id} for the role'+ role
                        return callback(ruleEntry)
	return callback new Error "Entry not found for the role: #{role}"

    getRulesbyRole: (role, callback) ->
        res = { 'rules': [] }
	@db.rulesdb.forEach (key,val) ->
	    res.rules.push val if val
	util.log 'listing...'
	return callback(res)

    # For POST /tokens, POST /rules endpoint
    add: (type, entry, callback) ->
        @checkentryschema type, entry, (error) =>
            unless error instanceof Error
                # add entry into stormkeeper db
	        keeperdb = @getRelativeDB type
                @db.keeperdb.set entry.id, entry, ->
                    return callback(entry)
            else
                util.log 'entry check: '+ error
                return callback new Error "#{entry.id} entry not added!"

    # For PUT /tokens, PUT /rules endpoint
    update: (type, entry, callback) ->
        if entry.id
            @add type, entry, (res) =>
                callback res
        else
            callback new Error "Could not find ID! #{id}"

    # To remove entry-id from DB
    remove: (type, entry, callback) ->
        util.log 'StormKeeper in DEL entry'
	keeperdb = @getRelativeDB type
        @db.keeperdb.rm entry.id, =>
            util.log "removed entry ID: #{entry.id}"
            callback({result:200})

    #This function is to decrement expiry in token
    DecrementExpiryInToken: (token,connectionTick) ->
        util.log 'StormKeeper in cleanup tokens' + connectionTick
        for tokenKey, tokenValue of token
            if tokenKey == 'expiry'
                token[tokenKey] = (token[tokenKey] - connectionTick) 
                #TODO - Cleanup only for stormflash agents
                if token[tokenKey] < 1
                    @db.tokensdb.rm token.id, =>
                    util.log "removed token ID: #{token.id}"

    #This function resets the tokenExpiry to tokenMaxDuration. This function is called upon "PUT /tokens/:id" 
    resetTokenExpiry: (token) ->
        try
            util.log "resetTokenExpiry for #{token.id}"
	    tokenEntry = @db.tokensdb.get token.id
	    if tokenEntry
                for tokenKey, tokenValue of tokenEntry
                    if tokenKey == 'expiry'
                        tokenEntry[tokenKey] = tokenMaxDuration 
                        util.log tokenEntry
        catch err
            util.log err

    #Update the expiry value for every time tick
    updateTokenExpiry: (connectionTick)->
        try
            @db.tokensdb.forEach (key,val) ->
                entry = db.get key
                if entry
                    @DecrementExpiryInToken entry
            res = getTokens()
            util.log res
        catch err
            util.log err

    setInterval (=>
        util.log "Cleanuptimer triggered for tokens"
        @updateTokenExpiry(cleanupInterval)
    ), cleanupInterval

# SINGLETON CLASS OBJECT
instance = null
module.exports = (args) ->
    if not instance?
        instance = new StormKeeper args
    return instance
