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

  fetch: (model, options = {}) ->
    collection = model.className
    assert @routes[collection], "No route found for #{collection}"
    path = @routes[collection].index
    @_request path, options.params, (result) =>
      items = @itemsFromResult(result)
      console.log "[ResourceClient] Found #{items.length} items"
      for item in items
        id = item[@IDField] # TODO: Configurable
        assert id, "[ResourceClient] There's no field '#{@IDField}' that is configured as IDField in incoming object"
        uri = {collection: collection, id: id}
        @appContext.updateOrCreate uri, item
  
  itemsFromResult: (result) ->
    result

  _request: (path, params, callback) ->
    url = @base + path
    params or= {}

    success = (result) ->
      callback(result)
    error = (res, err) =>
      return @sync.didFailAuth() if res.status == 401
      console.log "Fetch failed", res, err
    
    $.ajax url, {data: params, dataType: "json", success: success, error: error, headers: @headers}
  
  addHeader: (header, value) ->
    @headers[header] = value

module.exports = ResourceClient