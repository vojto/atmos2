# Atmosphere Spine Model Adapter
# -----------------------------------------------------------------------------

Spine       = require('spine')
Atmosphere  = require('./synchronizer')
require('./lawnchair_spine')

Spine.Model.Atmosphere =
  extended: ->
    @extend Spine.Model.Lawnchair
    @bind 'save', (object) ->
      Atmosphere.instance.markObjectChanged(object)

  sync: (params) ->
    @fetch()
    Atmosphere.instance.fetch(@, params)