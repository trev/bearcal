(function() {

  (function($, window, document) {
    return $.widget("a07.BearCal", {
      options: {
        startDate: new Date(),
        period: 12,
        scrollPeriod: 4,
        monthFullName: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      },
      _options: {
        loadedMonths: [],
        displayPosition: []
      },
      _setDate: function() {
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
        var blanks, daycount, dayshtml, i;
        dayshtml = "";
        daycount = 0;
        blanks = this._getDayOfWeek(year, month, 1);
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
          dayshtml += "<div class=\"day_box\" rel=\"" + year + "-" + month + "-" + (i + 1) + "\">" + (i + 1) + "</div>\n";
          daycount++;
          i++;
        }
        while (daycount < 42) {
          dayshtml += "<div class=\"empty_day_box\"></div>";
          daycount++;
        }
        return dayshtml;
      },
      _getMonth: function(year, month) {
        this._setLoadedMonths(year, month);
        return "<div class=\"month_box\">\n  <div class=\"month_header\">" + this.options.monthFullName[month] + " " + year + "</div>\n  <div class=\"month_wrapper\">\n    " + (this._getWeekdaysHtml()) + "\n    " + (this._getDaysHtml(year, month)) + "\n  </div>\n</div>";
      },
      _setLoadedMonths: function(year, month) {
        var date;
        if (this._options.loadedMonths.length !== 0) {
          date = this._options.loadedMonths[0].split("-");
          if (new Date(year, month).getTime() < new Date(date[0], date[1]).getTime()) {
            return this._options.loadedMonths.unshift(year + "-" + month);
          } else {
            return this._options.loadedMonths.push(year + "-" + month);
          }
        } else {
          return this._options.loadedMonths.push(year + "-" + month);
        }
      },
      _getCalendar: function() {
        var calendarhtml, i, month, year;
        calendarhtml = "<div class=\"prev_months\">Previous " + this.options.scrollPeriod + " Months</div>";
        calendarhtml += "<div class=\"year_box clearfix\">\n  <div class=\"slider_container clearfix\">\n";
        year = this.options.startDate.getFullYear();
        month = this.options.startDate.getMonth();
        i = 0;
        while (i < this.options.period) {
          if (month > 11) {
            month = 0;
            year++;
          }
          calendarhtml += this._getMonth(year, month);
          month++;
          i++;
        }
        calendarhtml += "</div></div>";
        return calendarhtml += "<div class=\"next_months\">Next " + this.options.scrollPeriod + " Months</div>";
      },
      _getMonthsByPeriod: function(year, month, period) {
        var date, html, i, movement, result, results, tmp, _i, _len, _month;
        movement = period < 0 ? -1 : 1;
        i = Math.abs(period);
        results = [];
        html = "";
        while (i !== 0) {
          month += movement;
          tmp = month % 12;
          year = tmp === 0 ? year + movement : year;
          _month = tmp < 0 ? tmp + 12 : tmp;
          results.push(year + "-" + _month);
          --i;
        }
        if (movement === -1) {
          results.reverse();
        }
        for (_i = 0, _len = results.length; _i < _len; _i++) {
          result = results[_i];
          date = result.split("-");
          html += this._getMonth(date[0], date[1]);
        }
        return html;
      },
      _splitDate: function(index) {
        var date, i;
        date = this._options.loadedMonths[index].split("-");
        i = 0;
        while (i < date.length) {
          date[i] = parseInt(date[i]);
          i++;
        }
        return date;
      },
      _create: function() {
        var _this = this;
        this.element.append(this._getCalendar());
        $('.prev_months').click(function() {
          var animatemargin, date, height;
          if (!$('.slider_container').is(':animated')) {
            height = parseFloat($('.slider_container').css("marginTop")) - $('.month_box').outerHeight(true);
            animatemargin = height + $('.month_box').outerHeight(true);
            date = _this._splitDate(0);
            return $('.slider_container').prepend(_this._getMonthsByPeriod(date[0], date[1], -4)).css({
              "marginTop": height + "px"
            }).animate({
              marginTop: animatemargin + "px"
            }, 1000);
          }
        });
        return $('.next_months').click(function() {
          var date, height;
          if (!$('.slider_container').is(':animated')) {
            height = $('.month_box').outerHeight(true) - parseFloat($('.slider_container').css("marginTop"));
            date = _this._splitDate(_this._options.loadedMonths.length - 1);
            return $('.slider_container').append(_this._getMonthsByPeriod(date[0], date[1], 4)).animate({
              marginTop: -height + "px"
            }, 1000);
          }
        });
      },
      _init: function() {
        return this._setDate();
      },
      destroy: function() {},
      _setOption: function(key, value) {},
      getPeriod: function() {
        return this.options.period;
      }
    });
  })(jQuery, window, document);

}).call(this);
