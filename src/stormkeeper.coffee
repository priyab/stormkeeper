class StormKeeper

	validate = require('json-schema').validate
	uuid = require('node-uuid')
	util = require('util')

    schema =
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

	constructor : ->
	    util.log 'stormkeeper constructor called'
	    @db = require('dirty') '/var/db/stormkeeper.db'
	    @db.on 'load', ->
	        util.log 'loaded stormkeeper.db'
	        @forEach (key,val) ->
	            util.log 'found ' + key if val 

	checkschema: (token) ->
	    if schema?
		    util.log 'performing schema validation on token posting'
		    return new Error "token data is missing" unless token
		    result = validate token, schema 
		    error = new Error("Invalid token posting!")
		    throw error unless result.valid
		    return result

	new: (data,id) ->
		token = {}
		if id
		    token.id = id
	    else
            token.id = uuid.v4()
        # TODO - Need to update proper body here
        token.data = data
	    return token

	getTokensById: (id, callback) ->
	    util.log "looking up token ID: #{id}"
	    entry = @db.get id
	    if entry
	        result = @checkschema token
	        util.log result
	        return callback new Error "Invalid token retrieved: #{result.errors}" unless result.valid 
	        return callback(token)
	    else
	        return callback new Error "Token not found: #{token}"

	getTokens: ->
		res = { 'tokens': [] }
		@db.forEach (key,val) ->
		    res.tokens.push val if val
		util.log 'listing...'
		return res

    # For POST /tokens endpoint
    add: (token, callback) ->
        @checkschema token, (error) =>
            unless error instanceof Error
                # add token into stormkeeper db
                @db.set token.id, token, ->
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
            @db.rm token.id, =>
                util.log "removed token ID: #{token.id}"
                callback({result:200})

# SINGLETON CLASS OBJECT
instance = null
module.exports = (args) ->
    if not instance?
        instance = new StormKeeper args
    return instance
