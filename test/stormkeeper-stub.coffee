# STUB unit testing code here

assert = require("chai").assert
expect = require("chai").expect
should = require("chai").should
config = require("../package.json").config
StormKeeper = require("../src/stormkeeper")
StormRule = require("../src/stormkeeper").StormRule
StormToken = require("../src/stormkeeper").StormToken

# test data for StormRule
ruleValidJSONall =
    name: "name1"
    rules: [ "GET /agents/serialkey/:key", "GET /agents/:id/bolt" ]
    role: "agent"
    
ruleValidJSONnoName =
    rules: [ "GET /agents/serialkey/:key", "GET /agents/:id/bolt" ]
    role: "agent"
    
ruleValidJSONemptyRules =
    rules: []
    name: "name2"
    role: "agent"

ruleInvalidJSONnoRole =
    name: "name1"
    rules: [ "GET /agents/serialkey/:key", "GET /agents/:id/bolt" ]

ruleInvalidJSONnoRules =
    name: "name1"
    role: "agent"

describe "StormRule schema validations", ->
    it "1. check stormrule with all fields", ->
        rule = new StormRule(null,ruleValidJSONall)
        expect(rule).to.be.an.instanceof(StormRule)
        expect(rule).to.contain.key('id')
        #console.log "    created new Rule: ", rule.id
        expect(rule.data).to.contain.key('name')
        expect(rule.data).to.contain.key('role')
        expect(rule.data).to.contain.key('rules')

    it "2. check stormrule without optional field 'name'", ->
        rule = new StormRule(null,ruleValidJSONnoName)
        expect(rule).to.contain.key('id')
        #console.log "    created new Rule: ", rule.id
        expect(rule.data).to.not.contain.key('name')
        expect(rule.data).to.contain.key('role')
        expect(rule.data).to.contain.key('rules')
        
    it "3. check stormrule with mandatory field 'rules' as empty list", ->
        rule = new StormRule(null,ruleValidJSONemptyRules)
        expect(rule).to.contain.key('id')
        #console.log "    created new Rule: ", rule.id
        expect(rule.data).to.contain.key('name')
        expect(rule.data).to.contain.key('role')
        expect(rule.data).to.contain.key('rules')

    it "4. check stormrule without mandatory field 'role'", ->
        #expect(new StormRule(null,ruleInvalidJSONnoRole)).to.throw(Error)
        #expect(new StormRule(null,ruleInvalidJSONnoRole)).to.be.an.instanceof(Error)
        #expect(new StormRule(null,ruleInvalidJSONnoRole)).to.throw("unable to validate passed in data during StormData creation! { valid: false,\n  errors: [ { property: 'role', message: 'is missing and it is required' } ] }")
        #expect(new StormRule(null,ruleInvalidJSONnoRole)).to.throw(Error, "unable to validate passed in data during StormData creation! { valid: false,\n  errors: [ { property: 'role', message: 'is missing and it is required' } ] }")

        try
            expect(new StormRule(null,ruleInvalidJSONnoRole)).to.throw(Error)
        catch error
            #expect(error.message).to.have.string("unable to validate passed in data during StormData creation! { valid: false,\n  errors: [ { property: 'role', message: 'is missing and it is required' } ] }")
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("is missing and it is required")
            expect(error.message).to.have.string("role")

# test data for StormToken
tokenValidJSONall =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoName =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoLastModified =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoUserData =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"

tokenValidEmptyUserData =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: []

tokenValidNoAccountID =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoUserEmail =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn"} ]

tokenValidNoDomainId =
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoRuleId =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoIdentityId =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: 36000
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidNoValidity =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidInvalidValidity =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: "string"
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

tokenValidIllegalValidity =
    domainId: "0ef4477f-bf67-409d-b49a-35b25a6e5c56"
    identityId: "e3911ff2-8d71-46a3-b5a8-89d8d3673902"
    ruleId: "53969231-2438-4e10-9a52-862869c5d56d"
    validity: -500
    name: "validToken1"
    lastModified: "timestamp"
    userData: [ {"accountId":"qrstc127-bf53-44a6-9bc4-46e0d213zkmn","userEmail":"priyabrata.sahoo@calsoftlabs.com"} ]

describe "StormToken schema validations", ->
    @timeout 5000
    it "01. check stormtoken with all fields", ->
        token = new StormToken(null,tokenValidJSONall)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).to.contain.key('name')
        expect(token.data).to.contain.key('lastModified')
        expect(token.data).to.contain.key('userData')
        expect(token.data.userData).to.be.a('array')
        expect(token.data.userData[0]).to.contain.key('accountId')
        expect(token.data.userData[0]).to.contain.key('userEmail')

    it "02. check stormtoken without optional field 'name'", ->
        token = new StormToken(null,tokenValidNoName)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).not.to.contain.key('name')
        expect(token.data).to.contain.key('lastModified')
        expect(token.data).to.contain.key('userData')
        expect(token.data.userData).to.be.a('array')
        expect(token.data.userData[0]).to.contain.key('accountId')
        expect(token.data.userData[0]).to.contain.key('userEmail')

    it "03. check stormtoken without optional field 'lastModified'", ->
        token = new StormToken(null,tokenValidNoLastModified)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).to.contain.key('name')
        expect(token.data).not.to.contain.key('lastModified')
        expect(token.data).to.contain.key('userData')
        expect(token.data.userData).to.be.a('array')
        expect(token.data.userData[0]).to.contain.key('accountId')
        expect(token.data.userData[0]).to.contain.key('userEmail')

    it "04. check stormtoken without optional field 'userData'", ->
        token = new StormToken(null,tokenValidNoUserData)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).to.contain.key('name')
        expect(token.data).to.contain.key('lastModified')
        expect(token.data).not.to.contain.key('userData')

    it "05. check stormtoken without optional field 'accountId' of 'userData'", ->
        token = new StormToken(null,tokenValidNoAccountID)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).to.contain.key('name')
        expect(token.data).to.contain.key('lastModified')
        expect(token.data).to.contain.key('userData')
        expect(token.data.userData).to.be.a('array')
        expect(token.data.userData[0]).not.to.contain.key('accountId')
        expect(token.data.userData[0]).to.contain.key('userEmail')

    it "06. check stormtoken without optional field 'userEmail' of 'userData'", ->
        token = new StormToken(null,tokenValidNoUserEmail)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).to.contain.key('name')
        expect(token.data).to.contain.key('lastModified')
        expect(token.data).to.contain.key('userData')
        expect(token.data.userData).to.be.a('array')
        expect(token.data.userData[0]).to.contain.key('accountId')
        expect(token.data.userData[0]).not.to.contain.key('userEmail')

    it "07. check stormtoken with optional field 'userEmail' as empty array", ->
        token = new StormToken(null,tokenValidEmptyUserData)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        expect(token.data).to.contain.key('identityId')
        expect(token.data).to.contain.key('validity')
        expect(token.data).to.contain.key('name')
        expect(token.data).to.contain.key('lastModified')
        expect(token.data).to.contain.key('userData')
        expect(token.data.userData).to.be.a('array')
        expect(token.data.userData).to.be.empty

    it "08. check stormtoken without mandatory field 'domainId'", ->
        try
            expect(token = new StormToken(null,tokenValidNoDomainId)).to.throw(Error)
        catch error
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("is missing and it is required")
            expect(error.message).to.have.string("domainId")

    it "09. check stormtoken without mandatory field 'ruleId'", ->
        try
            expect(token = new StormToken(null,tokenValidNoRuleId)).to.throw(Error)
        catch error
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("is missing and it is required")
            expect(error.message).to.have.string("ruleId")

    it "10. check stormtoken without mandatory field 'identityId'", ->
        try
            expect(token = new StormToken(null,tokenValidNoIdentityId)).to.throw(Error)
        catch error
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("is missing and it is required")
            expect(error.message).to.have.string("identityId")

    it "11. check stormtoken without mandatory field 'validity'", ->
        try
            expect(token = new StormToken(null,tokenValidNoValidity)).to.throw(Error)
        catch error
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("is missing and it is required")
            expect(error.message).to.have.string("validity")

    it "12. check stormtoken with 'validity' value as string", ->
        try
            expect(token = new StormToken(null,tokenValidInvalidValidity)).to.throw(Error)
        catch error
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("string value found, but a number is required")
            expect(error.message).to.have.string("validity")

    it "13. check stormtoken with 'validity' value as -ve number", ->
        try
            expect(token = new StormToken(null,tokenValidIllegalValidity)).to.throw(Error)
        catch error
            #expect(error.message).to.have.string("unable to validate passed in data during StormData creation!")
            expect(error.message).to.have.string("expected { Object (id, data, ...) } to be a function")


###
    it "2. check stormtoken validity reduces by time", (done) ->
        keeper = new StormKeeper config
        token = new keeper.StormToken(null, tokenValidNoLastmodified)
        expect(token).to.be.an.instanceof(StormToken)
        expect(token).to.contain.key('id')
        expect(token.data).to.contain.key('name')
        expect(token.data).to.contain.key('ruleId')
        expect(token.data).to.contain.key('domainId')
        console.log "------------------------- 1", token.id
        match = keeper.tokens.get token.id
        console.log "------------------------- 2", match

        setTimeout (->
            console.log "--------------- 3", token.validity
            done()
        ), 3000
###

return



