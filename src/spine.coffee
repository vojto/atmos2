# Atmosphere Spine Model Adapter
# -----------------------------------------------------------------------------

Spine       = require('spine')
Atmosphere  = require('./synchronizer')
require('./lawnchair_spine')

Spine.Model.Atmosphere =
  extended: ->
    @extend Spine.Model.Lawnchair
    spineSave = @::["save"]
    @::["save"] = (args...) ->
      spineSave.call(this, args...)
      if args[0]? && args[0].remote == true
        Atmosphere.instance.markObjectChanged(this)


  sync: (params) ->
    @fetch()
    Atmosphere.instance.fetch(@, params)