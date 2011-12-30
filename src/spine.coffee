# Atmosphere Spine Model Adapter
# -----------------------------------------------------------------------------

Spine       = require('spine')
Atmosphere  = require('./synchronizer')

Spine.Model.Atmosphere =
  extended: ->

  
  fetchRemote: (params) ->
    Atmosphere.instance.fetch(@collection(), params)