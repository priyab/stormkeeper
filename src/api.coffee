stormkeeper = require('./stormkeeper') @include

##
# STORMKEEPER /tokens REST end-points

@include = ->
    @get '/tokens': ->
        res = stormkeeper.getTokens()
        util.log res
        @send res

    @get '/tokens/:id', ->
        stormkeeper.getEntriesById 'TOKENS', @params.id, (res) =>
            util.log res
            unless res instanceof Error
                @send res
            else
                @next 404 

    @post '/tokens', ->
        util.log @body
        entry = stormkeeper.newEntry @body, @params.id
        stormkeeper.add 'TOKENS', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid token posting! #{res}"

    @put '/tokens/:id', ->

        # PUT VALIDATION
        # 1. need to make sure the incoming JSON is well formed
        # 2. destructure the inbound object with proper schema
        # 3. perform merge of inbound token data with existing data
        entry = stormkeeper.newEntry @body, @params.id

        stormkeeper.update 'TOKENS', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid token posting! #{res}"

    @del '/tokens/:id', ->
        # 1. remove the token entry from DB
        stormkeeper.remove 'TOKENS', @params.id, (res) =>
            unless res instanceof Error
                @send { deleted: true }
            else
                @next res

    @get '/rules': ->
        role = @req.query.role
        if role?
            stormkeeper.getRulesbyRole role, (res) =>
                util.log res
                unless res instanceof Error
                    @send res
                else
                    @next 404 
        else
            stormkeeper.getRules (res) =>
                util.log res
                unless res instanceof Error
                    @send res
                else
                    @next 404 

    @get '/rules/:id', ->
        stormkeeper.getEntriesById 'RULES', @params.id, (res) =>
            util.log res
            unless res instanceof Error
                @send res
            else
                @next 404 

    @post '/rules', ->
        util.log @body
        entry = stormkeeper.newEntry @body, @params.id
        stormkeeper.add 'RULES', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid rule posting! #{res}"

    @put '/rules/:id', ->

        # PUT VALIDATION
        # 1. need to make sure the incoming JSON is well formed
        # 2. destructure the inbound object with proper schema
        # 3. perform merge of inbound rule data with existing data
        entry = stormkeeper.newEntry @body, @params.id

        stormkeeper.update 'RULES', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @next new Error "Invalid rule posting! #{res}"

    @del '/rules/:id', ->
        # 1. remove the token entry from DB
        stormkeeper.remove 'RULES', @params.id, (res) =>
            unless res instanceof Error
                @send { deleted: true }
            else
                @next res
