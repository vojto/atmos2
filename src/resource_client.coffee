Spine = require('spine')
{assert} = require('./util')

class ResourceClient
  constructor: (options) ->
    @sync = options.sync
    @appContext = options.appContext
    
    @base = "http://localhost:3000/api"
    @routes =
      Course:
        index: "/projects.json"
      Page:
        index: '/pages.json'

  fetch: (model, params = {}) ->
    collection = model.className
    assert @routes[collection], "No route found for #{collection}"
    path = @routes[collection].index
    @_request path, params, (result) =>
      console.log "[ResourceClient] Received #{result.length} objects"
      model.fetch() # TODO: Away
      for item in result
        id = item._id # TODO: Configurable
        uri = {collection: collection, id: id}
        @sync.updateObject uri, item

  _request: (path, params, callback) ->
    url = @base + path
    params or= {}
    params.auth_key = @sync.authKey

    success = (result) ->
      callback(result)
    error = (res) =>
      return @sync.didFailAuth() if res.status == 401
    
    headers = 
      "Atmosphere-Auth-Key": @sync.authKey
    
    $.ajax url, {data: params, dataType: "json", success: success, error: error}

module.exports = ResourceClient