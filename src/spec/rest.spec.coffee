_ = require("underscore")._
Rest = require("../lib/rest").Rest
Config = require('../config').config

describe "Rest", ->

  beforeEach ->
    @rest = new Rest Config

  it "should initialize", ->
    expect(@rest).toBeDefined()

  it "should initialize with options", ->
    @rest = new Rest Config

    expected_options =
      config: Config
      host: "api.sphere.io"
      request:
        uri: "https://api.sphere.io/#{Config.project_key}"
        timeout: 20000
    expect(@rest._options).toEqual expected_options

describe "exports", ->

  beforeEach ->
    @rest = require("../lib/rest")
    spyOn(@rest, "doRequest")

  it "should call doRequest", ->
    @rest.doRequest()
    expect(@rest.doRequest).toHaveBeenCalled()

describe "Rest.GET", ->

  beforeEach ->
    @lib = require("../lib/rest")
    spyOn(@lib, "doRequest").andCallFake((options, callback)-> callback(null, null, {id: "123"}))
    spyOn(@lib, "doAuth").andCallFake((config, callback)-> callback({access_token: "foo"}))

  it "should send GET request", (done)->
    opts = _.clone(Config)
    opts.access_token = "foo"
    rest = new Rest opts

    callMe = (e, r, b)->
      expect(b.id).toBe "123"
      done()
    rest.GET("/product-projections", callMe)

    expected_options =
      uri: "https://api.sphere.io/#{Config.project_key}/product-projections"
      method: "GET"
      headers:
        "Authorization": "Bearer foo"
      timeout: 20000
    expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))

  it "should send GET request withOAuth", (done)->
    rest = new Rest Config

    callMe = (e, r, b)->
      expect(b.id).toBe "123"
      done()
    rest.GET("/product-projections", callMe)

    expect(@lib.doAuth).toHaveBeenCalledWith(Config, jasmine.any(Function))
    expected_options =
      uri: "https://api.sphere.io/#{Config.project_key}/product-projections"
      method: "GET"
      headers:
        "Authorization": "Bearer foo"
      timeout: 20000
    expect(@lib.doRequest).toHaveBeenCalledWith(expected_options, jasmine.any(Function))
