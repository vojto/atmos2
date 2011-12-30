# Atmosphere Spine Model Adapter
# -----------------------------------------------------------------------------

Spine       = require('spine')
Atmosphere  = require('lib/atmosphere/synchronizer')

Spine.Model.Atmosphere =
  extended: ->

  
  fetchRemote: (params) ->
    Atmosphere.instance.fetch(@collection(), params)