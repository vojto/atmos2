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
      options = args[0]
      if options? && options.remote == true
        Atmosphere.instance.save(this, options)
    @::["changeID"] = (id) -> # TODO: Fix this mess
      @destroy()
      @id = id
      @newRecord = true
      @save()


  sync: (params) ->
    @fetch()
    Atmosphere.instance.fetch(@, params)