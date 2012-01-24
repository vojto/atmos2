# Fetching

Load data from local storage:

    Model.sync()

Options:

- `remote`:`boolean` If true load data from remote source and persists them in local storage, otherwise simply fetches local data. 
- `local`:`boolean` If true it won't persist data in local storage, only load them transiently
- `remove`:`boolean` If true, removes local objects that weren't in the retrieved collection
- `params`:`object` Params sent to server with HTTP request.
- `pathParams`:`object` Params used to update path
- `updateData`:`function` This function is called on each of items from the collection before it is persisted. Use it to alter the incoming data.


# Saving

Save object locally

    object.save()

Options:

- `remote`:`boolean` If true object is marked as changed and synced with the source immediately or the next time user is online.
- `sync`:`boolean` If true, object is sent synchronously: The request is made right away and its possible to add more options to it.

Options for synchronous saving: (`sync` must be `true`):

- `params`:`object` Params sent to server with HTTP request.
- `pathParams`:`object` Params used to update path
- `updateData`:`function` This function is called on each of items from the collection before it is persisted. Use it to alter the incoming data.

## Specifying options from the model

When saving asynchronously, the object is simply marked as changed and synced the next cycle. 

For these cases, it is possible to specify sync options from model:

    class Comment
      remoteSaveOptions: (record) ->
        params: {},
        pathParams: {},
        updateData: (data) -> data