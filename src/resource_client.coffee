Spine = require('spine')
{assert} = require('./util')

class ResourceClient
  constructor: (options) ->
    @sync = options.sync
    @appContext = options.appContext
    
    @base = null
    @routes = null
    @IDField = "id"

  fetch: (model, options = {}) ->
    collection = model.className
    assert @routes[collection], "No route found for #{collection}"
    path = @routes[collection].index
    @_request path, options.params, (result) =>
      console.log "[ResourceClient] Received #{result.length} objects"
      for item in result
        id = item[@IDField] # TODO: Configurable
        assert id, "[ResourceClient] There's no field '#{@IDField}' that is configured as IDField in incoming object"
        uri = {collection: collection, id: id}
        @sync.updateObject uri, item

  _request: (path, params, callback) ->
    url = @base + path
    params or= {}
    params.auth_key = @sync.authKey

    success = (result) ->
      callback(result)
    error = (res, err) =>
      return @sync.didFailAuth() if res.status == 401
      console.log "Fetch failed", res, err
    
    $.ajax url, {data: params, dataType: "json", success: success, error: error}

module.exports = ResourceClient