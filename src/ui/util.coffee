# turn given array to a map by using keyfn to
# extract a key for each element in arr.
mapify = curry (arr, keyfn) -> mixin {}, (map arr, (e) -> set {}, keyfn(e), e)...

# filter an array for only defined values
defined = filter I

# ensure elements in an array are uniq given a transform function
# applied to each element.
uniqfn = curry (as, fn) ->
    fned = as.map fn
    as.filter (v, i) -> fned.indexOf(fned[i]) == i

# generic accessor helper function
accessor = (path...) ->
    [ps..., pe] = path
    (e, v) ->
        ee = ps.reduce ((p,c) -> p?[c]), e
        if arguments.length > 1 then ee[pe] = v else ee[pe]

# find index of element where fn is truthy.
findindex = curry binary (as, fn, fr) ->
    len = as?.length || 0
    return -1 unless len
    i = fr || 0
    `for (;i < len; ++i) { if (fn(as[i])) return i }`
    -1

# helper to keep track of a timer
makeTimer = ->
    tim = null
    {
        start: (ms, fn) ->
            @stop()
            tim = setTimeout fn, ms
        stop: ->
            clearTimeout tim if tim
            tim = null
    }

module.exports = {mapify, defined, uniqfn, accessor, findindex, makeTimer}
