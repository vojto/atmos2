Spine = require('spine')
{assert} = require('./util')

class ResourceClient
  # Lifecycle
  # ---------------------------------------------------------------------------

  constructor: (options) ->
    @atmos = options.atmos
    @app_context = options.app_context

    @base = null
    @routes = {}
    @_headers = {}
    @_id_field = '_id'

  # Fetching
  # ---------------------------------------------------------------------------

  fetch: (collection, options = {}, callback) ->
    path = @_path(collection, "index", options)
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

  # Saving
  # ---------------------------------------------------------------------------

  save: (object, options = {}) ->
    uri = @app_context.objectURI(object)
    path = @_pathForURI(uri, options.action, options)
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
      path = @_path(options.collection, options.action, options)
    else if options.object
      path = @_path_for_object(options.object, options.action, options)
    else
      path = options
    @request path, options.data, callback

  # Routing
  # ---------------------------------------------------------------------------

  _path: (collection, action, options = {}) ->
    ### Creates path for collection/action pair.

    **Options**

      - `path_params` if path contains additional params, e.g. `/foo/:bar_id`,
      you can specify their values as object, e.g. `{bar_id: 5}`
      - `params` params that will be used as query string, e.g. specify
      `{bar: 5}` to get url `/foo?bar=5`

    **Return value**

    A route object, e.g. `{method: 'get', path: '/foo', query: 'bar=5'}`

    ###
    route_path = if @routes[collection] then @routes[collection][action] else null

    if route_path
      [method, path] = route_path.split(" ")
    else
      method  = @_method_for_action(action)
      path    = '/' + collection.toLowerCase() + 's'

    if options.path_params?
      path = path.replace(":#{param}", value) for param, value of options.path_params

    route = {method: method, path: path}
    route.query = $.param(options.params) if options.params?
    route

  _method_for_action: (action) ->
    ### Returns default method for action passed. ###
    methods =
      'index': 'get',
      'create': 'post',
      'update': 'put',
      'delete': 'delete'
    methods[action]

  request: (route, data, callback) ->
    ### Makes an AJAX request to path specified. ###
    # TODO: This should use route, right???
    contentType = "application/x-www-form-urlencoded"
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
    path = {path: path} if typeof path == 'string'
    url = @base + path.path
    url += "?#{path.query}" if path.query
    options.type or= path.method
    $.ajax url, options


  add_header: (header, value) ->
    @_headers[header] = value

module.exports = ResourceClient