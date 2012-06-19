class ResourceCache
  # Storing objects
  # ---------------------------------------------------------------------------

  store_objects: (path, objects) ->
    ### Stores resulting objects in cache.

    **Arguments:**

    - `path` Path object that will be used to identify a request.
    E.g.: `{method: 'get', path: '/users/list'}`
    - `objects` Resulting objects formatted as array of objects.
    E.g.: `[{name: 'foo', age: 20}, {name: 'bar', age: 21}]`
    Objects should also contain value for the `id` field.
    ###

    # 1. Store objects
    object_keys = for object in objects
      @_store_object(object)

    request_key = @_object_checksum(path)
    request_key = "a.cache.request.#{request_key}"

    localStorage[request_key] = JSON.stringify(object_keys)

  _store_object: (object) ->
    key = object.id || @_object_checksum(object)
    key = "a.cache.object.#{key}"
    localStorage[key] = JSON.stringify(object)
    key


  # Helpers
  # ---------------------------------------------------------------------------

  _object_checksum: (object) ->
    text = JSON.stringify(object)
    acc = 1
    acc *= text[i].charCodeAt(0) for i in [0...text.length]
    acc % 1000000000


module.exports = ResourceCache