Lawnchair       = require('./vendor/lawnchair')

module.exports =
  prepareStore: (name, callback) ->
    return callback(@_lawnchairStore) if @_lawnchairStore?
    model = this
    new Lawnchair {name: name}, ->
      model._lawnchairStore = this
      callback(this)