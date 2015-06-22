
describe 'entity.lookup', ->

    it 'exposes a global lookup of {chat_id: entity}', ->
        assert.isObject entity.lookup

describe 'entity.init', ->

    it 'resets the entity.lookup', ->
        entity.lookup.ec1 = myent:true
        entity.init()
        assert.equal keys(entity.lookup).length, 0

describe 'entity.idof', ->

    it 'extract the chat_id of an entity', ->
        assert.equal entity.idof(id:{chat_id:'ec1',gaia_id:'eg1'}), 'ec1'

describe 'entity.need', ->

    beforeEach ->
        entity.init()
        entity.need.wait = 3

    afterEach ->
        entity.need.fetch = ->

    it 'gathers a bunch of ids then fetch them', (cb) ->
        entity.need 'ec1'
        entity.need 'ec2'
        entity.need 'ec3'
        entity.need.fetch = (ids) ->
            assert.deepEqual ids, ['ec1', 'ec2', 'ec3']
            cb()

    it 'dedupes the ids', (cb) ->
        entity.need 'ec1'
        entity.need 'ec1'
        entity.need 'ec1'
        entity.need.fetch = (ids) ->
            assert.deepEqual ids, ['ec1']
            cb()

    it 'populates entity.lookup with fetching:true for each non-existing', (cb) ->
        entity.need 'ec1'
        assert.isObject entity.lookup.ec1
        assert.deepEqual entity.lookup.ec1, {id:{chat_id:'ec1'},fetching:true}
        entity.need.fetch = -> cb()

    it 'marks existing as fetching:true', (cb) ->
        entity.lookup.ec1 = {id:{chat_id:'ec1'},myent:true}
        entity.need 'ec1'
        assert.isObject entity.lookup.ec1
        assert.deepEqual entity.lookup.ec1, {id:{chat_id:'ec1'},fetching:true,myent:true}
        entity.need.fetch = -> cb()
