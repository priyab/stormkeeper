##
# STORMKEEPER /tokens REST end-points

StormKeeper = require './stormkeeper'

@include = ->

    agent = @settings.agent

    ###
    # only uncomment during development...
    @get '/tokens': ->
        @send agent.tokens.list()
    ###

    # API for /tokens
    @post '/tokens': ->
        @send agent.authorize( new StormKeeper.StormToken( null,@body) )

    @get '/tokens/:id': ->
        match = agent.tokens.get @params.id
        if match?
            copy = agent.extend( {}, match )
            copy.rule = agent.rules.get match.ruleId
            @send copy
        else
            @send 404

    @put '/tokens/:id': ->
        @send new Error "updating token currently not supported!"
        ###
        match = agent.tokens.get @params.id
        if match?
            @send agent.authorize match, @body
        else
            @send 404
        ###

    @del '/tokens/:id': ->
        match = agent.tokens.entries[@params.id]
        if match?
            agent.revoke match
            @send 204 
        else
            @send 404

    # API for /rules
    @get '/rules': ->
        @send agent.rules.list()

    @post '/rules': ->
        @send agent.authorize( new StormKeeper.StormRule( null,@body) )

    @get '/rules/:id': ->
        match = agent.rules.get @params.id
        if match?
            @send match
        else
            @send 404

    @put '/rules/:id': ->
        @send new Error "updating rule currently not supported!"
        ###
        match = agent.tokens.get @params.id
        if match?
            @send agent.authorize match, @body
        else
            @send 404
        ###

    @del '/rules/:id': ->
        match = agent.rules.entries[@params.id]
        if match?
            agent.revoke match
            @send 204 
        else
            @send 404
