
# prefer global to window for unit tests to expose functions in global
# scope.
do (glob = (global ? window)) ->

    # expose trifl in global scope
    trifl = require 'trifl'
    trifl.expose glob

    # in app notification system
    glob.notr = require 'notr'
    notr.defineStack 'def', 'body', {top:'3px', right:'15px'}

    # expose some selected tagg functions
    trifl.tagg.expose glob, ('ul li div span a i b u s button p label
    input table thead tbody tr td th textarea br pass img h1 h2 h3 h4
    hr'.split(' '))...

    # and fnuc
    require('fnuc').expose glob

    # expose all conv functions
    glob.conv = require './models/conv'
