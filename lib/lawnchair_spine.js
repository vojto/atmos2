(function() {
  var LawnchairStore, Spine;

  Spine = require('spine');

  LawnchairStore = require('./lawnchair_store');

  Spine.Model.Lawnchair = {
    extended: function() {
      this.extend(LawnchairStore);
      this.change(this.saveLawnchair);
      return this.fetch(this.loadLawnchair);
    },
    saveLawnchair: function(record, type) {
      var _this = this;
      return this.prepareStore(this.name, function(store) {
        var data, id, record, _ref, _results;
        store.nuke();
        _ref = _this.records;
        _results = [];
        for (id in _ref) {
          record = _ref[id];
          data = JSON.parse(JSON.stringify(record));
          data.key = data.id;
          delete data.id;
          _results.push(store.save(data));
        }
        return _results;
      });
    },
    loadLawnchair: function() {
      var _this = this;
      return this.prepareStore(this.name, function(store) {
        return store.all(function(records) {
          var record;
          records = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = records.length; _i < _len; _i++) {
              record = records[_i];
              record.id = record.key;
              delete record.key;
              _results.push(record);
            }
            return _results;
          })();
          return _this.refresh(records);
        });
      });
    }
  };

}).call(this);
