Spine = require('spine')
{assert} = require('./util')

class ResourceClient
  constructor: (options) ->
    @atmos = options.atmos
    @app_context = options.app_context

    @base = null
    @routes = {}
    @_headers = {}
    @_id_field = '_id'
    @_data_format = "form" # "json"

  fetch: (model, options = {}) ->
    collection = model.className
    path = @_find_path(collection, "index", options)
    ids = []
    @request path, {}, (items) =>
      unless items?
        console.log "[ResourceClient] Items not found in response", result
        return
      ids = @update_from_items(collection, items, options)
      @_remove_objects_not_in_list(collection, ids, options.removeScope) if options.remove == true
      options.success() if options.success

  update_from_items: (collection, items, options) ->
    ids = []
    for item in items
      uri = {collection: collection}
      object = @update_from_item(uri, item, options)
      ids.push(object.id)
    ids

  update_from_item: (uri, item, options = {}) ->
    item.id = item[@_id_field]
    assert item.id, "[ResourceClient] There's no field '#{@_id_field}' that is configured as _id_field in incoming object"
    uri.id or= item.id
    options.updateData(item) if options.updateData?
    if options.updateFromData?
      options.updateFromData(uri, item, @_update_from_data)
    else
      @_update_from_data(uri, item)

  _update_from_data: (uri, data) =>
    object = @atmos.updateOrCreate(uri, data)
    object

  _remove_objects_not_in_list: (collection, ids, scope) ->
    @atmos.removeObjectsNotInList(collection, ids, scope)

  save: (object, options = {}) ->
    uri = @app_context.objectURI(object)
    path = @_find_pathForURI(uri, options.action, options)
    data = options.data || @app_context.dataForObject(object)
    data[@_id_field] = object.id unless data[@_id_field]?
    data = options.prepareData(data, options) if options.prepareData?
    @request path, data, (result) =>
      if options.sync
        object.save()
        uri = @app_context.objectURI(object)
      @update_from_item(uri, result, options)

  execute: (options, callback) ->
    if typeof options == 'string'
      path = {method: 'get', path: options}
    else if options.collection
      path = @_find_path(options.collection, options.action, options)
    else if options.object
      path = @_find_pathForObject(options.object, options.action, options)
    else
      path = options
    @request path, options.data, callback

  _find_pathForObject: (object, action, options) ->
    uri = @app_context.objectURI(object)
    @_find_pathForURI(uri)

  _find_pathForURI: (uri, action, options) ->
    options.pathParams    or= {}
    options.pathParams.id or= uri.id
    @_find_path(uri.collection, options.action, options)

  _find_path: (collection, action, options = {}) ->
    path = if @routes[collection] then @routes[collection][action] else null
    if path
      [method, path] = path.split(" ")
    else
      method  = @_method_for_action(action)
      path    = '/' + collection.toLowerCase() + 's'

    if options.pathParams?
      path = path.replace(":#{param}", value) for param, value of options.pathParams
    route = {method: method, path: path}
    route.query = $.param(options.params) if options.params?
    route

  _method_for_action: (action) ->
    methods =
      'index': 'get',
      'create': 'post',
      'update': 'put',
      'delete': 'delete'
    methods[action]

  request: (path, data, callback) ->
    proceed = =>
      contentType = "application/x-www-form-urlencoded"
      if @_data_format == "json"
        data = JSON.stringify(data)
        contentType = "application/json"
      success = (result) ->
        callback(result) if callback
      error = (res, err) =>
        if res.status == 401
          console.log "failed with error 401 #{err}"
          return @atmos.didFailAuth()
        console.log "Request failed #{res} #{err}", res, err
      options =
        dataType: "json"
        success: success
        error: error
        _headers: @_headers
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
    @_headers[header] = value

module.exports = ResourceClient