Spine = require('spine')
{assert} = require('./util')

class ResourceClient
  constructor: (options) ->
    @sync = options.sync
    @appContext = options.appContext
    
    @base = null
    @headers = {}
    @routes = null
    @IDField = "id"
    @dataCoding = "form" # "json"

  fetch: (model, options = {}) ->
    console.log "[ResourceClient] Fetching with options", options
    collection = model.className
    path = @_findPath(collection, "index", options)
    ids = []
    @_request path, {}, (result) =>
      items = @itemsFromResult(result)
      unless items?
        console.log "[ResourceClient] Items not found in response", result
        return
      console.log "[ResourceClient] Found #{items.length} items"
      for item in items
        item.id = item[@IDField]
        assert item.id, "[ResourceClient] There's no field '#{@IDField}' that is configured as IDField in incoming object"
        ids.push(item.id)
        uri = {collection: collection, id: item.id}
        options.updateData(item) if options.updateData?
        @sync.updateOrCreate(uri, item)
        @sync.markURISynced(uri)
      @_removeObjectsNotInList(collection, ids, options.removeScope) if options.remove == true
      console.log "[ResourceClient] Finished fetch"
  
  _removeObjectsNotInList: (collection, ids, scope) ->
    @sync.removeObjectsNotInList(collection, ids, scope)
  
  itemsFromResult: (result) ->
    result

  save: (object, options = {}) ->
    uri = @appContext.objectURI(object)
    console.log "Syncing object #{uri.id}", uri, options
    path = @_findPath(uri.collection, options.action, options)
    data = options.data || @appContext.dataForObject(object)
    data[@IDField] = object.id unless data[@IDField]?
    data = options.prepareData(data, options) if options.prepareData?
    @_request path, data, (result) =>
      result.id = result[@IDField] # TODO: Something smarter
      assert result.id, "[ResourceClient] There's no field '#{@IDField}' that is configured as IDField in incoming object"
      console.log "[ResourceClient] Finished save #{result.id}"
      if options.sync
        object.save()
        uri = @appContext.objectURI(object)
      options.updateData(result) if options.updateData?
      @sync.updateOrCreate(uri, result)
      @sync.markURISynced(uri)

  execute: (options, callback) ->
    path = @_findPath(options.collection, options.action, options)
    @_request path, options.data, callback

  _findPath: (collection, action, options = {}) ->
    assert @routes[collection], "No route found for #{collection}"
    path = @routes[collection][action]
    assert path, "No route found for #{collection}/#{action}"
    [method, path] = path.split(" ")
    if options.pathParams?
      path = path.replace(":#{param}", value) for param, value of options.pathParams
    route = {method: method, path: path}
    route.query = $.param(options.params) if options.params?
    route

  _request: (path, data, callback) ->
    proceed = =>
      url = @base + path.path
      url += "?#{path.query}" if path.query
      method = path.method
      contentType = "application/x-www-form-urlencoded"
      if @dataCoding == "json"
        data = JSON.stringify(data)
        contentType = "application/json" 
      success = (result) ->
        callback(result)
      error = (res, err) =>
        if res.status == 401
          console.log "failed with error 401 #{err}"
          return @sync.didFailAuth()
        console.log "Fetch failed #{res} #{err}", res, err
      options = 
        type: method
        dataType: "json"
        success: success
        error: error
        headers: @headers
        contentType: contentType
      options.data = data if data?
      $.ajax url, options

    if @beforeRequest?
      @beforeRequest(proceed)
    else
      proceed()

  addHeader: (header, value) ->
    @headers[header] = value

module.exports = ResourceClient