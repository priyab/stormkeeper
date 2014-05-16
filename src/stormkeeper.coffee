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
		name: "tokens"
		type: "object"
		additionalProperties: false
		properties:
			id: { type:"string","required":false}
			name: { type:"string","required":false}
			domainId: { type:"string","required":true}
			identityId: { type:"string","required":true}
			rulesId: { type:"string","required":true}
			expiry: { type:"number","required":true}
			lastModified: { type:"string","required":false}
			userData:
				type: "array"
				items:
					type: "object"
					required: false
					additionalProperties: true
					properties:
						accountId: {"type":"string", "required":false}
						userEmail: {"type":"string", "required":false}

	ruleschema =
		name : "rules"
		type : "object"
		additionalProperties : false
		properties :
			id: {"type":"string","required":false}
			name: {"type":"string","required":false}
			rules: {"type":"array","required":true}
			role: {"type":"string","required":true}

	constructor: ->
		util.log 'stormkeeper constructor called'

		@db =
			tokensdb: require('dirty') '/var/stormkeeper/tokens.db'
			rulesdb: require('dirty') '/var/stormkeeper/rules.db'

		@db.tokensdb._writeStream.on 'error', (err) ->
			util.log err
		@db.rulesdb._writeStream.on 'error', (err) ->
			util.log err

		@db.tokensdb.on 'load', ->
			util.log 'loaded tokens.db'
			@forEach (key,val) ->
				util.log 'Tokens found ' + key if val
		@db.rulesdb.on 'load', ->
			util.log 'loaded rules.db'
			@forEach (key,val) ->
				util.log 'Rules found ' + key if val

		setInterval (=>
			#util.log "Cleanuptimer triggered for tokens"
			@updateTokenExpiry(cleanupInterval)
		), cleanupInterval

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
				keeperDb = @db.tokensdb
			when "RULES"
				keeperDb = @db.rulesdb
		return keeperDb

	checkentryschema: (type, entry, callback) ->
		if type == 'TOKENS'
			entryschema = tokenschema
		if type == 'RULES'
			util.log 'performing ruleschema validation on a new entry posting'
			entryschema = ruleschema
			util.log 'siva'
		if entryschema?
			util.log 'performing entryschema validation on a new entry posting'
			return new Error "Entry data is missing" unless entry
			result = validate entry, entryschema
			error = new Error("Invalid entry posting!")
			throw error unless result.valid
			callback(result)
		else
			return callback new Error("No valid schema to compare:")

	getEntriesById: (type, id, callback) ->
		util.log "looking up entry ID: #{id}"
		keeperdb = @getRelativeDB type
		util.log "siva1 looking up entry ID: #{id}"
		entry = keeperdb.get id
		util.log "siva2 looking up entry ID: #{id}"
		if entry?
			@checkentryschema type, entry, (result) =>
				util.log result
				return callback new Error "Invalid entry retrieved: #{result.errors}" unless result.valid
				return callback(entry)
		else
			return callback new Error "Entry not found: #{entry.id}"

	getTokens: ->
		res =
			tokens: []
		@db.tokensdb.forEach (key,val) ->
			res.tokens.push val if val
			util.log 'listing...'
		return res

	getRules: (usertype, callback) ->
		rules = {}
		@db.rulesdb.forEach (key,rule) ->
			util.log "inspecting #{usertype} for #{key} = "+util.inspect rule
			if usertype?
				util.log "siva1"+util.inspect rule

				for rulekey, rulevalue of rule
					if rulevalue == usertype
						util.log "siva"+util.inspect rule
						return callback [ rule ]
			else
				# if the actual data is at the top
				rules[key] = rule unless key in rules
				# if the actual data is at the bottom
				# rules[key] = rule
		callback (entry for entry of rules)

	# For POST /tokens, POST /rules endpoint
	add: (type, entry, callback) ->
		if type? and entry? and entry.id
			util.log util.inspect 'siva:'+entry.id
			@checkentryschema type, entry, (error) =>
				util.log util.inspect entry
				unless error instanceof Error
					# add entry into stormkeeper db
					keeperdb = @getRelativeDB type
					util.log util.inspect entry.id
					keeperdb.set entry.id, entry, ->
						return callback(entry)
				else
					util.log 'entry check: '+ error
					callback new Error "#{entry.id} entry not added!"
		else
			callback new Error "Invalid entry!!"


	# For PUT /tokens, PUT /rules endpoint
	update: (type, entry, callback) ->
		if type? and entry? and entry.id
			@add type, entry, (res) =>
				callback res if callback?
		else
			callback new Error "Could not find ID! #{id}" if callback?

	# To remove entry-id from DB
	remove: (type, entry, callback) ->
		util.log 'StormKeeper in DEL entry'
		keeperdb = @getRelativeDB type
		if entry?
			keeperdb.rm entry.id, =>
				util.log "removed entry ID: #{entry.id}"
				callback({result:200})

	#This function is to decrement expiry in token
	DecrementExpiryInToken: (token,connectionTick) ->
		util.log 'StormKeeper in cleanup tokens' + connectionTick
		for tokenKey, tokenValue of token
			if tokenKey == 'expiry'
				token[tokenKey] = (token[tokenKey] - connectionTick)
				util.log util.inspect token[tokenKey]
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
			@db.tokensdb.forEach (key,entry) ->
				if entry
					@DecrementExpiryInToken entry, connectionTick
			res = @getTokens()
			#util.log util.inspect res
		catch err
			util.log err

# SINGLETON CLASS OBJECT
instance = null
module.exports = (args) ->
	if not instance?
		instance = new StormKeeper args
	return instance
