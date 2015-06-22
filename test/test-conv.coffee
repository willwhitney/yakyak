
describe 'conv.lookup', ->

    beforeEach ->
        conv.init()

    it 'exposes a global lookup of {conv_id: conversation}', ->
        assert.isObject conv.lookup

describe 'conv.idof', ->

    it 'extracts the string id of a conversation', ->
        assert.equal conv.idof(conversation_id:id:'c1'), 'c1'

describe 'conv.count', ->

    it 'counts the number of conversations in conv.lookup', ->
        conv.init()
        assert.equal conv.count(), 0
        conv.lookup.c1 = {}
        assert.equal conv.count(), 1
        conv.lookup.c2 = {}
        assert.equal conv.count(), 2

describe 'conv.init', ->

    beforeEach ->
        conv.init()

    it 'resets the conv.lookup when used wit no arguments', ->
        conv.lookup.c1 = myconv:true
        conv.init()
        assert.equal conv.count(), 0

    it 'resets the conv.lookup with conversations given converstation_state', ->
        state = [
            {
                conversation_id: id: 'c1'
                conversation:
                    conversation_id: id: 'c1'
                    name:'conv1'
            }
            {
                conversation_id: id: 'c2'
                conversation:
                    conversation_id: id: 'c2'
                    name:'conv2'
            }
        ]
        conv.init state
        assert.deepEqual conv.lookup.c1, state[0]
        assert.deepEqual conv.lookup.c2, state[1]

describe 'convFromEvent', ->

    it 'does nothing unless an conversation_id', ->
        assert.equal conv.fromEvent({}), null

    it 'constructs a minimal structure if conversation_id', ->
        c = conv.fromEvent e = conversation_id:id:'c1'
        assert.equal c.conversation_id.id, 'c1'
        assert.equal c.conversation.conversation_id.id, 'c1'
        assert.deepEqual c.conversation.current_participant, []
        assert.deepEqual c.conversation.read_state, []
        assert.deepEqual c.event, []
        self = c.conversation.self_conversation_state
        assert.equal self.self_read_state.latest_read_timestamp, 0
        assert.isTrue self.sort_timestamp - Date.now() * 1000 < 500

    it 'adds read_state from sender and self_event_state', ->
        e =
            conversation_id:id:'c1'
            sender_id:
                gaia_id:'gi1'
                chat_id:'ci1'
            self_event_state:user_id:
                gaia_id:'gi2'
                chat_id:'ci2'
        c = conv.fromEvent e
        assert.equal c.conversation?.read_state?[0]?.chat_id, 'ci1'
        assert.equal c.conversation?.read_state?[0]?.gaia_id, 'gi1'
        assert.equal c.conversation?.read_state?[1]?.chat_id, 'ci2'
        assert.equal c.conversation?.read_state?[1]?.gaia_id, 'gi2'

    it 'adds current_participant from sender and self_event_state', ->
        e =
            conversation_id:id:'c1'
            sender_id:
                gaia_id:'gi1'
                chat_id:'ci1'
            self_event_state:user_id:
                gaia_id:'gi2'
                chat_id:'ci2'
        c = conv.fromEvent e
        assert.equal c.conversation?.current_participant?[0]?.participant_id?.chat_id, 'ci1'
        assert.equal c.conversation?.current_participant?[0]?.participant_id?.gaia_id, 'gi1'
        assert.equal c.conversation?.current_participant?[1]?.participant_id?.chat_id, 'ci2'
        assert.equal c.conversation?.current_participant?[1]?.participant_id?.gaia_id, 'gi2'

    it 'sets event timestamp as sort_timestamp', ->
        e =
            conversation_id:id:'c1'
            timestamp: 123
        c = conv.fromEvent e
        assert.equal c.conversation.self_conversation_state.sort_timestamp, 123



describe 'conv.addEvent', ->

    beforeEach ->
        conv.init()

    it 'creates the conv if not there', ->
        conv.addEvent
            conversation_id:id:'c1'
        assert.isObject conv.lookup.c1

    it 'inserts the event by appending', ->
        conv.addEvent e1 =
            conversation_id:id:'c1'
            event_id:'ev1'
        conv.addEvent e2 =
            conversation_id:id:'c1'
            event_id:'ev2'
        assert.deepEqual conv.lookup.c1.event, [e1, e2]

    it 'overwrites if same event_id', ->
        conv.addEvent e1 =
            conversation_id:id:'c1'
            event_id:'ev1'
        conv.addEvent e2 =
            conversation_id:id:'c1'
            event_id:'ev1'
        assert.deepEqual conv.lookup.c1.event, [e2]

    it 'overwrites if same client_generated_id', ->
        conv.addEvent e1 =
            conversation_id:id:'c1'
            event_id:'ev1'
            self_event_state:client_generated_id:'cg1'
        conv.addEvent e2 =
            conversation_id:id:'c1'
            event_id:'ev2'
            self_event_state:client_generated_id:'cg1'
        assert.deepEqual conv.lookup.c1.event, [e2]

    it 'updates the sort time to that of the event', ->
        conv.addEvent
            conversation_id:id:'c1'
            event_id:'ev1'
        ts = Date.now() * 1000 + 500
        assert.isTrue conv.lookup.c1.conversation.self_conversation_state.sort_timestamp < ts
        conv.addEvent
            conversation_id:id:'c1'
            event_id:'ev1'
            timestamp: ts # set it
        assert.equal conv.lookup.c1.conversation.self_conversation_state.sort_timestamp, ts

    it 'doesnt update to time of event if older', ->
        conv.addEvent
            conversation_id:id:'c1'
            event_id:'ev1'
        ts = Date.now() * 1000 - 500
        assert.isTrue conv.lookup.c1.conversation.self_conversation_state.sort_timestamp > ts
        conv.addEvent
            conversation_id:id:'c1'
            event_id:'ev1'
            timestamp: ts # set it
        assert.isTrue conv.lookup.c1.conversation.self_conversation_state.sort_timestamp != ts

    it 'generates a timestamp if not set in event', ->
        ts = Date.now() * 1000 - 500
        conv.addEvent
            conversation_id:id:'c1'
            event_id:'ev1'
            timestamp: ts
        assert.equal conv.lookup.c1.conversation.self_conversation_state.sort_timestamp, ts
        conv.addEvent
            conversation_id:id:'c1'
            event_id:'ev1'
        assert.isTrue conv.lookup.c1.conversation.self_conversation_state.sort_timestamp > ts



    # # add a chat message to conversation
    # addChatMessage: addChatMessage
    # # add a chat message placeholder
    # addChatMessagePlaceholder: addChatMessagePlaceholder
    # # add a watermark to conversation
    # addWatermark: addWatermark
    # adds a rename message
    # addRename: addRename

    # # the max number of unread. dictated by syncrecentconvs
    # MAX_UNREAD: MAX_UNREAD
    # # the number of unread messages in a conv
    # unread: unread
    # # is conversation quiet
    # isQuiet: isQuiet
    # # is conversation a pure hangout (audio/video)
    # isPureHangout: isPureHangout
    # # when was conversation las changed
    # lastChanged: lastChanged
    # # add a typing indicator
    # addTyping: addTyping
    # # prune typing indicators
    # pruneTyping: pruneTyping
    # # set the notification level of conv
    # setNotificationLevel: (conv_id, level) ->
    # # delete a conversation
    # deleteConv: (conv_id) ->
    # # remove participants from conv
    # removeParticipants: (conv_id, ids) ->
    # # add participants to conv
    # addParticipant: (conv_id, participant) ->
    # # XXX remove
    # replaceFromStates: (states) ->
    # # maybe request history
    # updateAtTop: (attop) ->
    # # splice in history
    # updateHistory: (state) ->
    # # XXX remove replace message with placeholder image
    # updatePlaceholderImage: ({conv_id, client_generated_id, path}) ->
    # # list all conversations
    # list: (sort = true) ->
