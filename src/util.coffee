assert = (expression, message) ->
  throw message if !expression

module.exports =
  assert:     assert