##
# STORMKEEPER /tokens REST end-points

@include = ->

    agent = @settings.agent
    log = agent.log

    @get '/tokens': ->
        log "#{@request.method} #{@request.url}"
        res = agent.getTokens()
        log "result", res
        @send res

    @get '/tokens/:id': ->
        log "#{@request.method} #{@request.url}"
        agent.getEntriesById 'TOKENS', @params.id, (res) =>
            log "result", res
            unless res instanceof Error
                @send res
            else
                @send 404

    @post '/tokens': ->
        log "#{@request.method} #{@request.url}"
        entry = agent.newEntry @body, ''
        agent.add 'TOKENS', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @send new Error "Invalid token posting! #{res}"

    @put '/tokens/:id': ->

        log "#{@request.method} #{@request.url}"
        # PUT VALIDATION
        # 1. need to make sure the incoming JSON is well formed
        # 2. destructure the inbound object with proper schema
        # 3. perform merge of inbound token data with existing data
        entry = agent.newEntry @body, @params.id

        agent.update 'TOKENS', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @send new Error "Invalid token posting! #{res}"

    @del '/tokens/:id': ->
        log "#{@request.method} #{@request.url}"
        # 1. remove the token entry from DB
        agent.remove 'TOKENS', @params.id, (res) =>
            unless res instanceof Error
                @send { deleted: true }
            else
                @send res

    @get '/rules': ->
        log "#{@request.method} #{@request.url}"
        try
            role = @request.query.role if @request.query.role?
            agent.getRules role, (rules) =>
                if rules? and rules.length > 0
                    log "#{@request.url}\n",rules
                    @send rules
                else
                    @send 404
        catch err
            @send err

    @get '/rules/:id': ->
        log "#{@request.method} #{@request.url}"
        agent.getEntriesById 'RULES', @params.id, (res) =>
            log res
            unless res instanceof Error
                @send res
            else
                @send 404

    @post '/rules': ->
        log "#{@request.method} #{@request.url}"
        entry = agent.newEntry @body, ''
        log "result",entry
        agent.add 'RULES', entry, (res) =>
            unless res instanceof Error
                log "result",res
                @send res
            else
                @send new Error "Invalid rule posting! #{res}"

    @put '/rules/:id': ->
        log "#{@request.method} #{@request.url}"
        # PUT VALIDATION
        # 1. need to make sure the incoming JSON is well formed
        # 2. destructure the inbound object with proper schema
        # 3. perform merge of inbound rule data with existing data
        entry = agent.newEntry @body, @params.id

        agent.update 'RULES', entry, (res) =>
            unless res instanceof Error
                @send res
            else
                @send new Error "Invalid rule posting! #{res}"

    @del '/rules/:id': ->
        # 1. remove the token entry from DB
        log "#{@request.method} #{@request.url}"
        agent.remove 'RULES', @params.id, (res) =>
            unless res instanceof Error
                @send { deleted: true }
            else
                @send res
