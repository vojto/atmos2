# About

This library allows building REST-based web applications that cache objects locally for better user experience and offline usage.

At the moment it only supports applications that utilize [Spine](https://github.com/maccman/spine) model layer.

# Current state

- Library contains some old code from atmos1, which used very different approach
- You're interested in `resource_client.coffee`
- For now it supports only fetching objects, and persisting their local cache.

# Plans

- Next step is to create objects locally, track changes, and push them to REST source. This was implemented before, but not with REST.
- Live change pushing and notifications through WebSocket

# Should I try it?

If you want a working library, then no. But the development is going fast, I expect to have a quite working version by the end of January 2012. 

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

    class List extends Spine.Model
      @configure 'List', 'title', 'kind', 'selfLink'

### Extend with Atmosphere

All you have to do is require Atmosphere's Spine adapter, and extend model with it.

    require('atmos2/lib/spine')
    
    class List extends Spine.Model
      @configure 'List', 'title', 'kind', 'selfLink'
      @extend Spine.Model.Atmosphere

Atmosphere will automatically use the local storage.

## Setting up the synchronizer

Do this somewhere, where it will be executed before anything else.

    Atmos = require('atmos2')
    
    atmos = new Atmos
    atmos.resourceClient.base = "https://www.googleapis.com/tasks/v1/users/@me"

As you can see, this example will work with Google Tasks API. But first, Atmosphere needs more information.

    atmos.resourceClient.routes =
      List:
        index: "/lists"
    atmos.resourceClient.addHeader "Authorization", "OAuth #{token}"
    atmos.resourceClient.IDField = "id"
    atmos.itemsFromResult = (result) -> result.items
    
* `routes` specifies path that will be hit on actions: index, create, update, delete. (TODO: Add others to the example.)
* `addHeader` adds header to every request. In this case, we're adding OAuth Authorization, which we've taken care of someplace else, so we have a token.
* `IDField` every retrieved object must have an ID. Some APIs expose this ID in field `id`, others `identifier`, so this settings lets you set it. If a record with empty ID will be retrieved, Atmosphere will throw an error.
* `itemsFromResult` is a function that will be used to get the items from object decoded from response JSON. In this case, we receive a JSON that looks like this: `{items: [...]}`, so we need to tell Atmosphere how to look for actual records.


## Fetching data

Now all you need to do is this:

    List.sync(remote: true)

Atmosphere will trigger event `refresh` once the data has been received. So your interface needs to query model for data again when this happens.


