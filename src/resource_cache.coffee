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

    request_key = @_request_key(path)
    @_local_write(request_key, object_keys)

  _store_object: (object) ->
    key = object.id || @_object_checksum(object)
    key = "a.cache.object.#{key}"
    @_local_write(key, object)
    key


  # Collecting objects
  # ---------------------------------------------------------------------------

  collect_objects: (path) ->
    ### Returns objects at some path. Should've the cache been not used before
    `null` will be returned instead. ###
    request_key = @_request_key(path)
    object_keys = @_local_read(request_key)
    objects = @_objects_for_keys(object_keys)
    objects

  _objects_for_keys: (keys) ->
    return null unless keys
    for key in keys
      @_local_read(key)


  # Helpers
  # ---------------------------------------------------------------------------

  _request_key: (path) ->
    key = @_object_checksum(path)
    "a.cache.request.#{key}"

  _object_checksum: (object) ->
    text = JSON.stringify(object)
    acc = 1
    acc *= text[i].charCodeAt(0) for i in [0...text.length]
    acc % 1000000000

  _local_write: (key, object) ->
    localStorage[key] = JSON.stringify(object)

  _local_read: (key) ->
    data = localStorage[key]
    if data then JSON.parse(data) else null

module.exports = ResourceCache