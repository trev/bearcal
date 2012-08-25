(function() {

  (function($, window, document) {
    return $.widget("a07.BearCal", {
      options: {
        startDate: new Date(),
        period: 12,
        monthFullName: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      },
      _getRowCount: function() {},
      _prepDate: function() {
        var date;
        if (typeof this.options.startDate !== "object") {
          date = this.options.startDate.split('/');
          return this.options.startDate = new Date(date[0], date[1], date[2]);
        }
      },
      _getDayOfWeek: function(year, month, day) {
        return new Date(year, month, day).getDay();
      },
      _getDaysInMonth: function(year, month) {
        return new Date(year, month, 0).getDate();
      },
      _getMonthsHtml: function() {
        var i, month, monthshtml, year;
        monthshtml = "";
        year = this.options.startDate.getFullYear();
        month = this.options.startDate.getMonth();
        i = 0;
        while (i < this.options.period) {
          if (month > 11) {
            month = 0;
            year++;
          }
          console.log('in');
          monthshtml += "<div class=\"month_box\">\n  <div class=\"month_header\">" + this.options.monthFullName[month] + " " + year + "</div>\n  <div class=\"month_wrapper\">\n    " + (this._getWeekdaysHtml()) + "\n    " + (this._getDaysHtml(year, month)) + "\n  </div>\n</div>";
          month++;
          i++;
        }
        return monthshtml;
      },
      _getWeekdaysHtml: function() {
        var day, weekdayshtml, _i, _len, _ref;
        weekdayshtml = "";
        _ref = this.options.days;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          day = _ref[_i];
          weekdayshtml += "<div class=\"wday_box\">" + (day.charAt(0)) + "</div>\n";
        }
        return weekdayshtml;
      },
      _getDaysHtml: function(year, month) {
        var blanks, daycount, dayshtml, empties, i, j, rowcount;
        dayshtml = "";
        daycount = 0;
        rowcount = 0;
        blanks = this.options.startDate.getDay();
        if (blanks > 0) {
          i = 0;
          while (i < blanks) {
            dayshtml += "<div class=\"empty_day_box\"></div>";
            daycount++;
            i++;
          }
        }
        i = 0;
        while (i < this._getDaysInMonth(year, month)) {
          if (daycount % 6 === 0) {
            rowcount++;
          }
          dayshtml += "<div class=\"day_box\" rel=\"\">" + (i + 1) + "</div>\n";
          daycount++;
          i++;
        }
        if (rowcount < 7) {
          empties = ((6 - rowcount) * 7) + (7 - this._getDayOfWeek(year, month, i));
          j = 0;
          while (j < empties) {
            dayshtml += "<div class=\"empty_day_box\"></div>";
            j++;
          }
        }
        return dayshtml;
      },
      _buildCalendar: function() {},
      _create: function() {
        console.log(this.options.startDate);
        return console.log(this._getMonthsHtml());
      },
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
