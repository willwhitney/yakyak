
module.exports = entity = {}

# entity lookup table. key is chat_id (as string), value is the entity.
entity.lookup = {}

# reset the entity lookup
entity.init = ->
    entity.lookup = {}

# extract the id of an entity
entity.idof = (e) -> e?.id?.chat_id

# construct a new bare bones entity from a chat_id
entity.fromChatId = (chat_id) -> {id:{chat_id}}

lookupOrCreate = (chat_id) ->
    entity.lookup[chat_id] ? entity.lookup[chat_id] = entity.fromChatId(chat_id)

entity.need = do ->
    gather = []
    timer = makeTimer()
    setFetching = set 'fetching', true
    appendToGather = tap (ent) -> gather.push ent.id.chat_id
    restartTimer = tap ->
        timer.start entity.need.wait, ->
            entity.need.fetch uniq(gather)
            gather = []
    sequence lookupOrCreate, setFetching, appendToGather, restartTimer

# for testing
entity.need.wait = 1000
entity.need.fetch = (ids) -> action 'getentity', ids
