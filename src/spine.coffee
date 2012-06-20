# Atmos Spine Model Adapter
# -----------------------------------------------------------------------------

# TODO: Refactor this into a separate module!

Spine = require('spine')
Atmos = require('./atmos')

pushed_models = {}

setup_model_for_push = (model) ->
  collection = pluralize(model.className)
  pushed_models[collection] = model

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
    collection  = pluralize(@className)
    setup_model_for_push(@)
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
  word = word.toLowerCase()
  if word.match /y$/
    word.replace /y$/, 'ies'
  else
    word + 's'

Atmos.ready = ->
  Atmos.bind 'update_object', ({collection, id, object}) ->
    model = pushed_models[collection]
    return console.log "collection #{collection} wasn't synced yet" if !model
    console.log 'updating', collection, id, object
    record = model.exists(id) || new model
    record.load(object)
    record.id = id
    record.save()
