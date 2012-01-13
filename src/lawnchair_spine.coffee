Spine           = require('spine')
LawnchairStore  = require('./lawnchair_store')

Spine.Model.Lawnchair =
  extended: ->
    @extend LawnchairStore
    @change @saveLawnchair
    @fetch @loadLawnchair
  
  saveLawnchair: (record, type) ->
    @prepareStore @name, (store) =>
      data = JSON.parse(JSON.stringify(record))
      data.key = data.id
      delete data.id
      store.save(data)
  
  loadLawnchair: ->
    @prepareStore @name, (store) =>
      store.all (records) =>
        records = for record in records
          record.id = record.key
          delete record.key
          record
        @refresh records