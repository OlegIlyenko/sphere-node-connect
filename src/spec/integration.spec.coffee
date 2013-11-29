_ = require("underscore")._
OAuth2 = require("../lib/oauth2").OAuth2
Rest = require("../lib/rest").Rest
Config = require('../config').config

_.each ["valid-ssl", "self-signed-ssl"], (mode)->
  isSelfSigned = mode is "self-signed-ssl"

  describe "Integration test (#{mode})", ->

    beforeEach ->
      if isSelfSigned
        @oa = new OAuth2
          config: Config.staging
          host: "auth.escemo.com"
          rejectUnauthorized: false
        @rest = new Rest
          config: Config.staging
          host: "api.escemo.com"
          oauth_host: "auth.escemo.com"
          rejectUnauthorized: false
      else
        @oa = new OAuth2
          config: Config.prod
        @rest = new Rest
          config: Config.prod

    afterEach ->
      @oa = null
      @rest = null

    it "should get access token", (done)->
      @oa.getAccessToken (error, response, body)->
        data = JSON.parse(body)
        expect(data.access_token).toBeDefined()
        done()

    it "should get products", (done)->
      @rest.GET "/products", (error, response, body)->
        expect(response.statusCode).toBe 200
        json = JSON.parse(body)
        expect(json).toBeDefined()
        results = json.results
        expect(results.length).toBeGreaterThan 0
        expect(results[0].id).toEqual jasmine.any(String)
        done()

    it "should return 404 if product is not found", (done)->
      @rest.GET "/products/123", (error, response, body)->
        expect(response.statusCode).toBe 404
        done()

    it "should create an delete custom object", (done)->
      data =
        container: "integration"
        key: "foo"
        value: "bar"
      payload = JSON.stringify(data)
      @rest.POST "/custom-objects", payload, (error, response, body)=>
        expect(response.statusCode).toBe 201
        @rest.DELETE "/custom-objects/integration/foo", (error, response, body)->
          expect(response.statusCode).toBe 200
          done()
