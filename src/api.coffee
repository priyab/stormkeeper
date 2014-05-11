stormkeeper = require('./stormkeeper') @include


##
# STORMKEEPER /tokens REST end-points

@include = ->
    @get '/tokens': ->
        res = stormkeeper.getTokens()
        util.log res
        @send res

    @get '/tokens/:id', loadToken, ->
        stormkeeper.getTokensById @params.id, (res) =>
            util.log token
            unless token instanceof Error
                @send token
            else
                @next 404 

    # POST/PUT TOKEN VALIDATION
    # 1. need to make sure that the incoming JSON is well formed
    # 2. destructure the inbound object with proper schema
    validateToken = ->
        util.log @body
        result = stormkeeper.checkshema @body
        util.log result
        return @next new Error "Invalid token posting!: #{result.errors}" unless result.valid
        @next()

    # helper routine for retrieving token data from dirty db
    loadToken = ->
        result = stormkeeper.getTokensById @params.id
        unless result instanceof Error
            @request.token = result
            @next()
        else
            return @next result

    @post '/tokens', validateToken, ->
        util.log @body
        token = stormkeeper.new @body, @params.id
        stormkeeper.add token, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid token posting! #{res}"

    @put '/tokens/:id', validateToken, ->
        # XXX - can have intelligent merge here

        # PUT VALIDATION
        # 1. need to make sure the incoming JSON is well formed
        # 2. destructure the inbound object with proper schema
        # 3. perform merge of inbound token data with existing data
        token = stormkeeper.new @body, @params.id

        stormkeeper.update token, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid token posting! #{res}"

    @del '/tokens/:id', loadToken, ->
        # 1. remove the token entry from DB
        stormkeeper.remove @request.token, (res) =>
            unless res instanceof Error
                @send { deleted: true }
            else
                @next res
