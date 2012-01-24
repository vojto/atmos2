# Fetching

Load data from local storage:

    Model.sync()
    
Loads data from remote source and persists them in local storage:

    Model.sync(remote: true)

Load data from remote source, but don't persist them in local storage

    Model.sync(remote: true, local: false)

Load data from remote source, and remove local objects that are not in the retrieved collection. 

    Model.sync(remote: true, remove: true)


# Saving

Save object locally

    object.save()

Save object locally and send remote request.

    object.save(remote: true)

Send remote request, save locally when finishes (wait for confirmation):

    object.save(remote: true, sync: true)