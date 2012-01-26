# About

Build REST web applications based on [Spine](http://spinejs.com/) that cache objects locally for better user experience and offline usage.

**Fetch objects from remote source**

    Task.sync(remote: true)

Makes request to the server fetching the data for collection "tasks". When done, it will trigger the `refresh` which updates the interface.

**Save object**

    task.save(remote:true)
    
This method will return instantly marking object as changed. A request will be made in the background.

# Current state

- You can fetch objects and cache them locally using `Model.sync(remote: true)`
- You can save local object and push it to remote service using `object.save(remote: true)`

# Plans

- Live change pushing and notifications through WebSocket

# Should I try it?

This is work in progress, feel free to try it, but it's not ready for real use.

# Getting Started

Take existing Spine app or create a new one.

## Add Atmosphere to slug.json

### Add Atmosphere

Add these modules to your `slug.json`:

    "dependencies": [
		…
    	"atmos2",
    	"atmos2/lib/spine"
  	],

## Setup your model

Let's say this is your current Spine model:

    class Task extends Spine.Model
      @configure 'Task', 'title', 'kind', 'selfLink'

### Extend with Atmosphere

All you have to do is require Atmosphere's Spine adapter, and extend model with it.

    require('atmos2/lib/spine')
    
    class Task extends Spine.Model
      @configure 'Task', 'title', 'kind', 'selfLink'
      @extend Spine.Model.Atmosphere

Atmosphere will automatically use the local storage.

## Setting up the synchronizer

Do this somewhere, where it will be executed before anything else.

    Atmos = require('atmos2')
    
    atmos = new Atmos
    atmos.resourceClient.base = "https://www.googleapis.com/tasks/v1/users/@me"

As you can see, this example will work with Google Tasks API. But first, Atmosphere needs more information.

    atmos.resourceClient.routes =
      Task:
        index: "/lists"
    atmos.resourceClient.addHeader "Authorization", "OAuth #{token}"
    atmos.resourceClient.IDField = "id"
    atmos.resourceClient.dataCoding = "json"
    atmos.resourceClient.itemsFromResult = (result) -> result.items
    
* `routes` specifies path that will be hit on actions: index, create, update, delete. (TODO: Add others to the example.)
* `addHeader` adds header to every request. In this case, we're adding OAuth Authorization, which we've taken care of someplace else, so we have a token.
* `IDField` every retrieved object must have an ID. Some APIs expose this ID in field `id`, others `identifier`, so this settings lets you set it. If a record with empty ID will be retrieved, Atmosphere will throw an error.
* `dataCoding` can be `form` or `json`, specifies in what format will be outgoing data encoding and sent. (Also, what `Content-Type` will be used)
* `itemsFromResult` is a function that will be used to get the items from object decoded from response JSON. In this case, we receive a JSON that looks like this: `{items: [...]}`, so we need to tell Atmosphere how to look for actual records.


## Fetching objects

    Task.sync(remote: true)

This will first fetch data from local storage triggering the `refresh` event, then make the network request, update local data, and trigger `refresh` event again.

## Sending objects

    task = new Task({title: "Task 2"})
    task.save(remote: true)

Calling `save` will first save the object locally, then it will make network request to save it again. `create` action will be used.

If you call `save` on already saved object, `update` action will be used. Atmosphere keeps track of all objects you saved with `remote` flag to differentiate between objects that have been sent previously and those once that haven't. 