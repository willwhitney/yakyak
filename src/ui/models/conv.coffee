
module.exports = conv = {}

# global conv.lookup. conversations keyed on conv_id
conv.lookup = null

# resets the state back to origin clearing the lookup.
conv._reset = ->
    conv.lookup = {}

# initial reset
conv._reset()
