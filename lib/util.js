(function() {
  var assert;

  assert = function(expression, message) {
    if (!expression) throw message;
  };

  module.exports = {
    assert: assert
  };

}).call(this);
