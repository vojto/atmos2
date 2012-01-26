Spine           = require('spine')

class Defaults extends Spine.Module
  @set: (key, value) ->
    localStorage["Defaults.#{key}"] = value
    
  @get: (key) ->
    localStorage["Defaults.#{key}"]
    
module.exports = Defaults
window.Defaults = Defaults