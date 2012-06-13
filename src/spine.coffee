# Atmos Spine Model Adapter
# -----------------------------------------------------------------------------

# TODO: Refactor this into a separate module!

Spine = require('spine')
Atmos = require('./atmos')

Spine.Model.Atmos =
  extended: ->
    spine_save = @::["save"]
    @::["save"] = (args...) ->
      atmos = Atmos.instance
      options = args[0]
      if options? && options.remote == true
        atmos_save(this, options)
      else
        spine_save.call(this, args...)

  sync: (params = {}) ->
    @fetch()
    atmos       = Atmos.instance
    collection  = pluralize(@className.toLowerCase())
    atmos.fetch collection, params, (objects) =>
      # TODO: Load them into memory! Somehow!
      console.log 'loading objects to class', objects, @
      @refresh(objects)

atmos_save = (object, options) ->
  atmos       = Atmos.instance
  class_name  = object.constructor.className
  collection  = pluralize(class_name.toLowerCase())
  data        = object.attributes()

  if object.isNew()
    atmos.create collection, data, options, (object) ->
      console.log 'create finished', object
  else
    atmos.update collection, data, options, (object) ->
      console.log 'create finished', object

pluralize = (word) ->
  if word.match /y$/
    word.replace /y$/, 'ies'
  else
    word + 's'