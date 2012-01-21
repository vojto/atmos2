Spine           = require('spine')
LawnchairStore  = require('./lawnchair_store')

class Defaults extends Spine.Module
  @extend LawnchairStore
  
  @set: (key, value) ->
    @prepareStore 'defaults', (store) ->
      store.save({key: key, value: value})
  
  @get: (key, callback) ->
    @prepareStore 'defaults', (store) ->
      store.get key, (object) ->
        callback(if object then object.value else null)
    
module.exports = Defaults