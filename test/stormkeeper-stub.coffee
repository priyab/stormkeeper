# STUB unit testing code here

assert = require("chai").assert
expect = require("chai").expect
should = require("chai").should
StormRule = require("../src/stormkeeper").StormRule


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
            expect(error.message).to.have.string("unable to validate passed in data during StormData creation! { valid: false,\n  errors: [ { property: 'role', message: 'is missing and it is required' } ] }")


