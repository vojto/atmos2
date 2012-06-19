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
    @request path, {}, (items, res) =>
      unless items?
        console.log "[ResourceClient] Items not found in response", res
        return

      for item in items
        item.id = item[@_id_field]
        assert item.id, "[ResourceClient] There's no field '#{@_id_field}' that is configured as _id_field in incoming object"

      callback(items)

  # Saving
  # ---------------------------------------------------------------------------

  create: (collection, object, options = {}, callback) ->
    options.action or= 'create'
    @_save(collection, object, options, callback)

  update: (collection, object, options = {}, callback) ->
    options.action or= 'update'
    @_save(collection, object, options, callback)

  _save: (collection, object, options = {}, callback) ->
    data             = object
    data[@_id_field] = object.id

    options.path_params     or= {}
    options.path_params.id  = data.id
    path = @_path(collection, options.action, options)

    @request path, data, (object, res) =>
      callback(object)

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
    path = if @routes[collection] then @routes[collection][action] else null

    unless path
      path = @_default_path(collection, action)

    [method, path] = path.split(" ")

    if options.path_params?
      path = path.replace(":#{param}", value) for param, value of options.path_params

    route = {method: method, path: path}
    route.query = options.params if options.params?
    route

  _default_path: (collection, action) ->
    ### Returns default route path for action passed. ###
    methods =
      'index': "get /#{collection}",
      'create': "post /#{collection}",
      'update': "put /#{collection}/:id",
      'delete': "delete /#{collection}/:id"
    methods[action]

  request: (route, data, callback) ->
    ### Makes an AJAX request.

    **Arguments**:

    - `route` Atmos route object, see `_path`
    - `data` Data payload for POST requests. To specify URL parameters
    in GET requests, use `query` key of route.
    - `callback(object, response)` Function to be called upon finishing
    request. If the response was valid JSON, `object` is parsed JSON.
    ###

    content_type = "application/x-www-form-urlencoded"

    complete = (res) =>
      try
        object = JSON.parse(res.responseText)
      catch error
        console.log 'unable to parse json', res.responseText, error
      @atmos.did_fail_auth() if res.status == 401
      callback(object, res)

    options =
      type:         route.method
      complete:     complete
      _headers:     @_headers
      content_type: content_type
      data:         data

    url = @base + route.path
    url += '?' + $.param(route.query) if route.query

    $.ajax url, options

  get: (path, callback) ->
    ### Shortcut method for making quick `get` request **without
    query params.** If you want to add query params, use `request`
    and pass a route object. ###
    @request {method: 'get', path: path}, {}, callback

  post: (path, data, callback) ->
    ### Shortcut for making quick `post` request. See `get`. ###
    @request {method: 'post', path: path}, data, callback

  add_header: (header, value) ->
    @_headers[header] = value

module.exports = ResourceClient