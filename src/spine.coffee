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
    @bind 'beforeCreate', (record) ->
      record.id = @_uuid()

  _uuid: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else r & 3 | 8
      v.toString 16
  
  # uid: -> @_uuid()

  sync: (params = {}) ->
    @fetch()
    atmos = Atmosphere.instance
    if atmos? && params.remote == true
      atmos.fetch(@, params)

