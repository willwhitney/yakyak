
describe 'conv.reset', ->

    it 'resets conv.lookup back to empty', ->
        conv.lookup['c1'] = {myconv:true}
        conv._reset()
        assert.equal keys(conv.lookup).length, 0

describe 'conv.lookup', ->

    beforeEach ->
        conv._reset()

    it 'exposes a global lookup of {conv_id: conversation}', ->
        assert.isObject conv.lookup


    # # reset all conversations
    # _reset: ->
    # # init from conversation states
    # _initFromConvStates: (convs) ->
    # # count number of conversations
    # count: ->
    # # add a conversation
    # add:add
    # # rename a conversation
    # rename: rename
    # # add a chat message to conversation
    # addChatMessage: addChatMessage
    # # add a chat message placeholder
    # addChatMessagePlaceholder: addChatMessagePlaceholder
    # # add a watermark to conversation
    # addWatermark: addWatermark
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
