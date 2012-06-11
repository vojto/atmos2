assert = (expression, message) ->
  throw message if !expression

pluralize = (word) ->
  if word.match /y$/
    word.replace /y$/, 'ies'
  else
    word + 's'

module.exports =
  assert:     assert
  pluralize:  pluralize