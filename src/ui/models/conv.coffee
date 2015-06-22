
module.exports = conv = {}

# global conv.lookup. conversations keyed on conv_id
# structure is:
#
# 'UgzCdRYtaABAQ': <conversation_state>
#
# Example:
# UgzCdRYtaABAQ:
#     conversation_id: id: 'UgzCdRYtaABAQ'
#     conversation:
#         conversation_id: id: 'UgzCdRYtaABAQ'
#         type: 'STICKY_ONE_TO_ONE'
#         name: null
#         self_conversation_state:
#             self_read_state:
#                 participant_id:
#                     gaia_id: '9466496385187'
#                     chat_id: '9466496385187'
#                 latest_read_timestamp: 1433706670714000
#             status: 'ACTIVE'
#             notification_level: 'RING'
#             view: [ 'INBOX_VIEW' ]
#             inviter_id:
#                 gaia_id: '1717679643843'
#                 chat_id: '1717679643843'
#             invite_timestamp: 1427958263680000
#             sort_timestamp: 1433705727309942
#             active_timestamp: 1427958327086000
#         read_state: [
#             {
#                 participant_id:
#                     gaia_id: '9466496385187'
#                     chat_id: '9466496385187'
#                 last_read_timestamp: 1433706670714000
#             }
#             {
#                 participant_id:
#                     gaia_id: '1717679643843'
#                     chat_id: '1717679643843'
#                 last_read_timestamp: 0
#             }
#         ]
#         otr_status: 'ON_THE_RECORD'
#         current_participant: [
#             {
#                 gaia_id: '1717679643843'
#                 chat_id: '1717679643843'
#             }
#             {
#                 gaia_id: '9466496385187'
#                 chat_id: '9466496385187'
#             }
#         ]
#         participant_data: [
#             {
#                 id:
#                     gaia_id: '9466496385187'
#                     chat_id: '9466496385187'
#                 fallback_name: 'Martin Algesten'
#             }
#             {
#                 id:
#                     gaia_id: '1717679643843'
#                     chat_id: '1717679643843'
#                 fallback_name: 'Peter Johansson'
#             }
#         ]
#     event: [
#         {
#             conversation_id: id: 'UgzCdRYtaABAQ'
#             sender_id:
#                 gaia_id: '1717679643843'
#                 chat_id: '1717679643843'
#             timestamp: 1431369749097532
#             self_event_state:
#                 user_id:
#                     gaia_id: '9466496385187'
#                     chat_id: '9466496385187'
#                 client_generated_id: null
#                 notification_level: {}
#             chat_message:
#                 annotation: []
#                 message_content:
#                     segment: [ {
#                         type: 'TEXT'
#                         text: 'Lugnt. Vi måste promenera från skanstull också.'
#                         formatting:
#                             bold: null
#                             italic: null
#                             strikethrough: null
#                             underline: null
#                         link_data: null
#                     } ]
#                     attachment: []
#             membership_change: null
#             conversation_rename: null
#             hangout_event: null
#             event_id: '7-G0T7-FAa34-0qEoodu0Y'
#             advances_sort_timestamp: null
#             otr_modification: null
#             event_otr: 'ON_THE_RECORD'
#         }
#     ]

conv.lookup = null

# get the conv_id of a conversation object
conv.idof = (c) -> c?.conversation_id?.id

# the total number of conversations
conv.count = -> keys(conv.lookup).length

# resets the state back to origin clearing the lookup.
# provide a conversation_state to init with.
conv.init = (state = []) ->
    conv.lookup = mapify state, conv.idof
    updated 'conv'

entFor     = ({chat_id, gaia_id}) -> {chat_id, gaia_id}
entOf      = (e) -> e.chat_id
entReadFor = ({chat_id, gaia_id}) -> {participant_id:{chat_id, gaia_id}, timestamp:0}
entReadOf  = (e) -> e.participant_id.chat_id

# construct a new entity list arr by adding on toadd using entForFn
# for each element and entOfFn to dedupe the result.
entityList = (entForFn, entOfFn, arr, toadd) ->
    uniqfn(entOfFn) concat arr, map(toadd, entForFn)

# does a best effort to construct a new conversation structure given
# an initial event.
conv.fromEvent = (e) ->
    return null unless conv_id = conv.idof(e)
    # some of these may not exist
    entities = defined [e.sender_id, e.self_event_state?.user_id]
    {
        conversation_id:id:conv_id
        conversation:
            conversation_id:id:conv_id
            read_state:entityList entFor, entOf, [], entities
            current_participant:entityList entReadFor, entReadOf, [], entities
            self_conversation_state:
                self_read_state:
                    latest_read_timestamp: 0
                sort_timestamp: e.timestamp ? Date.now() * 1000
        event: []
    }

# the sort timestamp accessor
sorttime = accessor 'conversation', 'self_conversation_state', 'sort_timestamp'

# the self read state accessor
selfread = accessor 'conversation', 'self_conversation_state',
    'self_read_state', 'latest_read_timestamp'

# pick the client_generated_if of an event
clientidof = (e) -> e?.self_event_state?.client_generated_id

# make tester function checking for same client_generated_id
isSameClientGeneratedId = (e) ->
    cid = clientidof(e)
    (t) -> cid and cid == clientidof(t)

# pick the event_id of an event
eventidof = (e) -> e.event_id

# make tester function for checking for the same event_id
isSameEventId = (e) ->
    eid = eventidof(e)
    (t) -> eid and eid == eventidof(t)

# lookup the index the given event should have in the conv.event array.
# 1. prefer client_generated_id
# 2. use event_id
# 3. add to end of array
indexForEvent = (e) ->
    c = conv.lookup[conv.idof(e)]
    # the event may already be in the events and should be replaced
    # first look by client
    cidx = findindex c.event, isSameClientGeneratedId(e)
    eidx = findindex c.event, isSameEventId(e)
    # prefer cidx to eidx
    if cidx >= 0 then cidx else if eidx >= 0 then eidx else c.event.length

lookupOrCreate = (e) ->
    conv_id = conv.idof(e)
    conv.lookup[conv_id] ? (conv.lookup[conv_id] = conv.fromEvent(e))

# adds one of chat_message, membership_change, conversation_rename,
# hangout_event or otr_modification
conv.addEvent = do ->
    # lookup or create the conv for the event, return an array tuple.
    lookup = (e) -> [e, lookupOrCreate(e)]
    # insert event at the correct place
    insertEvent = tap ([e, c]) ->
        c.event[indexForEvent(e)] = e
    updateSorttime = tap ([e, c]) ->
        # update the timestamp of the conversation
        newtime = e.timestamp ? Date.now() * 1000
        sorttime c, newtime if newtime > sorttime c
    sequence lookup, insertEvent, updateSorttime
