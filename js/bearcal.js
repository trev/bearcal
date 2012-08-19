(function() {

  (function($, window, document) {
    return $.widget("ui.BearCal", {
      options: {
        period: 12
      },
      _create: function() {},
      destroy: function() {},
      _setOption: function(key, value) {},
      getPeriod: function() {
        return this.options.period;
      }
    });
  })(jQuery, window, document);

}).call(this);
