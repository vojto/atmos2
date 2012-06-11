# Atmos Spine Model Adapter
# -----------------------------------------------------------------------------

# TODO: Refactor this into a separate module!

Spine = require('spine')
Atmos = require('./atmos')

Spine.Model.Atmos =
  extended: ->
    spineSave = @::["save"]
    @::["save"] = (args...) ->
      atmos = Atmos.instance
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
      record.id or= @_uuid()

  _uuid: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else r & 3 | 8
      v.toString 16

  # uid: -> @_uuid()

  # TODO: Start with this method, okaaay? Just make it work like spine.ajax, okaay?
  sync: (params = {}) ->
    @fetch()
    atmos = Atmos.instance
    atmos.fetch @className, params, (objects) =>
      console.log 'spine.atmos: finished fetch', objects
      # TODO: Load them into memory! Somehow!
      console.log 'loading objects to class', objects, @
      @refresh(objects)