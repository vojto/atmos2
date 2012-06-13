Spine = require('spine')
{assert, pluralize} = require('./util')

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

      for item in items
        item.id = item[@_id_field]
        assert item.id, "[ResourceClient] There's no field '#{@_id_field}' that is configured as _id_field in incoming object"

      callback(items)

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
      path    = '/' + pluralize(collection.toLowerCase())

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
    ### Makes an AJAX request specified by the `route` param. ###
    content_type = "application/x-www-form-urlencoded"

    error = (res, err) =>
      if res.status == 401
        console.log "failed with error 401 #{err}"
        return @atmos.did_fail_auth()
      console.log "Request failed #{res} #{err}", res, err

    options =
      type:         route.method
      dataType:     "json"
      success:      callback
      error:        error
      _headers:     @_headers
      content_type: content_type
      data:         data

    url = @base + route.path

    $.ajax url, options

  add_header: (header, value) ->
    @_headers[header] = value

module.exports = ResourceClient