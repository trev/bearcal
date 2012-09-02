(function() {

  (function($, window, document) {
    return $.widget("a07.BearCal", {
      options: {
        startDate: new Date(),
        period: 12,
        scrollPeriod: 4,
        monthFullName: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
        nthMonth: 4,
        nthMonthClass: "endrow"
      },
      _options: {
        loadedMonths: [],
        displayedMonths: []
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
        var nth;
        this._setLoadedMonths(year, month);
        if (this._options.displayedMonths.length < this.options.period) {
          this._setDisplayedMonths(year, month);
        }
        nth = this._options.loadedMonths.length % this.options.nthMonth;
        return "<div class=\"month_box " + (nth === 0 ? this.options.nthMonthClass : "") + "\">\n  <div class=\"month_header\">" + this.options.monthFullName[month] + " " + year + "</div>\n  <div class=\"month_wrapper\">\n    " + (this._getWeekdaysHtml()) + "\n    " + (this._getDaysHtml(year, month)) + "\n  </div>\n</div>";
      },
      _setLoadedMonths: function(year, month) {
        this._options.loadedMonths.push(year + "-" + month);
        return this._options.loadedMonths.sort(this._dateCompare);
      },
      _setDisplayedMonths: function(year, month, direction) {
        this._options.displayedMonths.push(year + "-" + month);
        this._options.displayedMonths.sort(this._dateCompare);
        if (typeof direction !== "undefined") {
          if (direction === -1) {
            this._options.displayedMonths.pop();
          }
          if (direction === 1) {
            return this._options.displayedMonths.shift();
          }
        }
      },
      _dateCompare: function(a, b) {
        a = a.split("-");
        b = b.split("-");
        return (new Date(a[0], a[1]).getTime()) - (new Date(b[0], b[1]).getTime());
      },
      _getCalendar: function() {
        var calendarhtml, i, month, year;
        calendarhtml = "<a href=\"#\" class=\"prev_months\">Previous " + this.options.scrollPeriod + " Months</a>";
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
        return calendarhtml += "<a href=\"#\" class=\"next_months\">Next " + this.options.scrollPeriod + " Months</a>";
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
          _month = tmp < 0 ? tmp + 12 : tmp;
          if (movement === -1) {
            year = _month === 11 ? year + movement : year;
          } else {
            year = _month === 0 ? year + movement : year;
          }
          results.push(year + "-" + _month);
          --i;
        }
        if (movement === -1) {
          results.reverse();
        }
        for (_i = 0, _len = results.length; _i < _len; _i++) {
          result = results[_i];
          date = result.split("-");
          if (~$.inArray(result, this._options.loadedMonths) === 0) {
            html += this._getMonth(date[0], date[1]);
          }
          this._setDisplayedMonths(date[0], date[1], movement);
        }
        return html;
      },
      _splitDate: function(index, source) {
        var date, i;
        date = source[index].split("-");
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
          var animatemargin, date, height, html;
          if (!$('.slider_container').is(':animated')) {
            height = parseFloat($('.slider_container').css("marginTop")) - $('.month_box').outerHeight(true);
            animatemargin = parseFloat($('.slider_container').css("marginTop")) + $('.month_box').outerHeight(true);
            animatemargin = animatemargin === $('.month_box').outerHeight(true) ? 0 : animatemargin;
            date = _this._splitDate(0, _this._options.displayedMonths);
            html = _this._getMonthsByPeriod(date[0], date[1], -4);
            if (html.length > 0) {
              $('.slider_container').prepend(html).css({
                "marginTop": height + "px"
              }).animate({
                marginTop: animatemargin + "px"
              }, 1000);
            } else {
              $('.slider_container').animate({
                marginTop: animatemargin + "px"
              }, 1000);
            }
          }
          return false;
        });
        return $('.next_months').click(function() {
          var date, height;
          if (!$('.slider_container').is(':animated')) {
            height = $('.month_box').outerHeight(true) - parseFloat($('.slider_container').css("marginTop"));
            date = _this._splitDate(_this._options.displayedMonths.length - 1, _this._options.displayedMonths);
            $('.slider_container').append(_this._getMonthsByPeriod(date[0], date[1], 4)).animate({
              marginTop: -height + "px"
            }, 1000);
          }
          return false;
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
