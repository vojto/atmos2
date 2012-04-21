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
    @subitems = {}

  fetch: (model, options = {}) ->
    collection = model.className
    path = @_findPath(collection, "index", options)
    ids = []
    @request path, {}, (result) =>
      items = @itemsFromResult(result)
      unless items?
        console.log "[ResourceClient] Items not found in response", result
        return
      ids = @updateFromItems(collection, items, options)
      @_removeObjectsNotInList(collection, ids, options.removeScope) if options.remove == true
      options.success() if options.success
  
  updateFromItems: (collection, items, options) ->
    ids = []
    for item in items
      uri = {collection: collection}
      object = @updateFromItem(uri, item, options)
      ids.push(object.id)
    ids
  
  updateFromItem: (uri, item, options = {}) ->
    item.id = item[@IDField]
    assert item.id, "[ResourceClient] There's no field '#{@IDField}' that is configured as IDField in incoming object"
    uri.id or= item.id
    options.updateData(item) if options.updateData?
    if options.updateFromData?
      options.updateFromData(uri, item, @_updateFromData)
    else
      @_updateFromData(uri, item)
  
  _updateFromData: (uri, data) =>
    object = @sync.updateOrCreate(uri, data)
    @sync.markURISynced(uri)
    object
  
  _removeObjectsNotInList: (collection, ids, scope) ->
    @sync.removeObjectsNotInList(collection, ids, scope)
  
  itemsFromResult: (result) ->
    result

  save: (object, options = {}) ->
    uri = @appContext.objectURI(object)
    path = @_findPathForURI(uri, options.action, options)
    data = options.data || @appContext.dataForObject(object)
    data[@IDField] = object.id unless data[@IDField]?
    data = options.prepareData(data, options) if options.prepareData?
    @request path, data, (result) =>
      if options.sync
        object.save()
        uri = @appContext.objectURI(object)
      @updateFromItem(uri, result, options)

  execute: (options, callback) ->
    if typeof options == 'string'
      path = {method: 'get', path: options}
    else if options.collection
      path = @_findPath(options.collection, options.action, options)
    else if options.object
      path = @_findPathForObject(options.object, options.action, options)
    else
      path = options
    @request path, options.data, callback

  _findPathForObject: (object, action, options) ->
    uri = @appContext.objectURI(object)
    @_findPathForURI(uri)
  
  _findPathForURI: (uri, action, options) ->
    options.pathParams    or= {}
    options.pathParams.id or= uri.id
    @_findPath(uri.collection, options.action, options)

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

  request: (path, data, callback) ->
    proceed = =>
      contentType = "application/x-www-form-urlencoded"
      if @dataCoding == "json"
        data = JSON.stringify(data)
        contentType = "application/json" 
      success = (result) ->
        callback(result) if callback
      error = (res, err) =>
        if res.status == 401
          console.log "failed with error 401 #{err}"
          return @sync.didFailAuth()
        console.log "Request failed #{res} #{err}", res, err
      options = 
        dataType: "json"
        success: success
        error: error
        headers: @headers
        contentType: contentType
      options.data = data if data?
      @ajax path, options
    if @beforeRequest?
      @beforeRequest(proceed)
    else
      proceed()
  
  ajax: (path, options = {}) ->
    path = {path: path} if typeof path == 'string'
    url = @base + path.path
    url += "?#{path.query}" if path.query
    options.type or= path.method
    $.ajax url, options
    

  addHeader: (header, value) ->
    @headers[header] = value

module.exports = ResourceClient