(function() {

  (function($, window, document) {
    return $.widget("a07.BearCal", {
      options: {
        startDate: new Date(),
        period: 12,
        monthFullName: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        day: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      },
      _getRowCount: function() {},
      _prepDate: function() {
        var date;
        if (typeof this.options.startDate !== "object") {
          date = this.options.startDate.split('/');
          return this.options.startDate = new Date(date[0], date[1], date[2]);
        }
      },
      _getFirstDayOfMonth: function() {
        return this.options.startDate.getDay();
      },
      _create: function() {},
      _init: function() {
        return this._prepDate();
      },
      destroy: function() {},
      _setOption: function(key, value) {},
      getPeriod: function() {
        return this.options.period;
      }
    });
  })(jQuery, window, document);

}).call(this);
