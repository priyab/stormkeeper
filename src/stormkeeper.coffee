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
	    name : "token"
	    type : "object"
	    additionalProperties : false
	    properties :
		    id: {"type":"string","required":false}
		    name: {"type":"string","required":false}
		    domain-id: {"type":"string","required":true}
		    identity-id: {"type":"string","required":true}
		    access-list:
			    items: {"type": "string"}
		    expiry: {"type":"string","required":true}
		    lastModified: {"type":"string","required":false}

    ruleschema =
	    name : "rule"
	    type : "object"
	    additionalProperties : false
	    properties :
		    id: {"type":"string","required":false}
		    name: {"type":"string","required":false}
		    method: {"type":"string","required":true}
		    url: {"type":"string","required":true}

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

	checktokenschema: (token) ->
	    if tokenschema?
		    util.log 'performing tokenschema validation on token posting'
		    return new Error "token data is missing" unless token
		    result = validate token, tokenschema 
		    error = new Error("Invalid token posting!")
		    throw error unless result.valid
		    return result

    new: ->
        id = uuid.v4()
        return id

	newToken: (data,id) ->
		token = {}
		if id
		    token.id = id
	    else
            token.id = @new() 
	    return token

	getTokensById: (id, callback) ->
	    util.log "looking up token ID: #{id}"
	    entry = @db.tokensdb.get id
	    if entry
	        result = @checktokenschema entry
	        util.log result
	        return callback new Error "Invalid token retrieved: #{result.errors}" unless result.valid 
	        return callback(entry)
	    else
	        return callback new Error "Token not found: #{token}"

	getTokens: ->
		res = { 'tokens': [] }
		@db.tokensdb.forEach (key,val) ->
		    res.tokens.push val if val
		util.log 'listing...'
		return res

    getRelativeDB: (type) ->
        util.log 'DB type: ' + type
		keeperDb = ''
		switch (type)
		    when "TOKENS"
		        keeperDb = db.tokensdb
		    when "RULES"
		        keeperDb = db.rulesdb
	    return keeperDb

    # For POST /tokens endpoint
    add: (token, callback) ->
        @checktokenschema token, (error) =>
            unless error instanceof Error
                # add token into stormkeeper db
                @db.tokensdb.set token.id, token, ->
                    callback(token)
            else
                util.log 'token check: '+ error
                return callback new Error "#{token.id} token not added!"

    # For PUT /tokens endpoint
    update: (token, callback) ->
        if token.id
            @add token, (res) =>
                callback res
        else
            callback new Error "Could not find ID! #{id}"

    # To remove token-id from DB
    remove: (token, callback) ->
            util.log 'StormKeeper in DEL token'
            @db.tokensdb.rm token.id, =>
                util.log "removed token ID: #{token.id}"
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
