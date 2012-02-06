Spine           = require('spine')

class Defaults extends Spine.Module
  @extend Spine.Events
  
  @set: (name, value) ->
    key = "Defaults.#{name}"
    previous = localStorage[key]
    localStorage[key] = value
    @trigger(name) unless previous == value
    value
    
  @get: (key) ->
    localStorage["Defaults.#{key}"]
    
module.exports = Defaults
window.Defaults = Defaults