# Fetching

    model.sync()
    # Loads data from local storage
    
    model.sync(remote: true)
    # Loads data from remote source and persists them in local storage
    
    model.sync(remote: true, local: false)
    # Loads data from remote source, but doesn't persist them in local storage