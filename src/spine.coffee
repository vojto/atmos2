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
      atmos = Atmosphere.instance
      options = args[0]
      if atmos? && options? && options.remote == true
        atmos.save(this, options)
      else
        spineSave.call(this, args...)
    @::["changeID"] = (id) -> # TODO: Fix this mess
      @destroy()
      @id = id
      @newRecord = true
      @save()


  sync: (params = {}) ->
    @fetch()
    atmos = Atmosphere.instance
    if atmos? && params.remote == true
      atmos.fetch(@, params)