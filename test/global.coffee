# jsdom to get a window object
jsdom           = require('jsdom').jsdom
global.window   = jsdom().defaultView
global.document = window.document
global.srlz     = require('jsdom').serializeDocument

global.document.__JSDOM = 'jsdom'

# insert globals
require '../src/ui/app.coffee'

global.chai   = require 'chai'

chai.use require 'sinon-chai'
sinon  = require 'sinon'

global.stub   = sinon.stub
global.spy    = sinon.spy
global.assert = chai.assert

# trifl globals
global.updated = ->
global.action = ->

# dummy localStorage
global.localStorage = {}
