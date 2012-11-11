(function() {

  (function($, window, document) {
    $.widget("a07.BearCal", {
      options: {
        startDate: new Date(),
        mode: "interactive",
        period: 12,
        monthScrollPeriod: 4,
        yearScrollPeriod: 12,
        monthFullName: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
        nthMonth: 4,
        nthMonthClass: "endrow",
        appendClass: "",
        scrollDirection: "vertical",
        animateSpeed: 500,
        nextPeriodHtml: function() {
          return "<a href=\"#\" class=\"next_months\">Next " + this.monthScrollPeriod + " months</a><a href=\"#\" class=\"next_year\">Next " + this.yearScrollPeriod + " months</a>";
        },
        prevPeriodHtml: function() {
          return "<a href=\"#\" class=\"prev_year\">Previous " + this.yearScrollPeriod + " months</a><a href=\"#\" class=\"prev_months\">Previous " + this.monthScrollPeriod + " months</a>";
        },
        highlightable: true,
        boxClass: {
          am: "am_box",
          pm: "pm_box",
          fullDay: "day_box"
        },
        trackClass: "track",
        defaultStatusType: "available",
        reverseTypes: {
          available: "unavailable",
          unavailable: "available"
        },
        hoverStates: {
          am: {
            available: "hover_available_am",
            unavailable: "hover_unavailable_am"
          },
          pm: {
            available: "hover_available_pm",
            unavailable: "hover_unavailable_pm"
          }
        },
        highlightStates: {
          am: {
            available: "highlight_available_am",
            unavailable: "highlight_unavailable_am"
          },
          pm: {
            available: "highlight_available_pm",
            unavailable: "highlight_unavailable_pm"
          }
        },
        setStates: {
          am: {
            available: "",
            unavailable: "unavailable am",
            booked: "booked am",
            delimiter: "delimiter_am"
          },
          pm: {
            available: "",
            unavailable: "unavailable pm",
            booked: "booked pm",
            delimiter: "delimiter_pm"
          }
        },
        json: false,
        jsonUrl: "",
        dontTrackStates: ["booked"]
      },
      _options: {
        loadedData: {},
        loadedMonths: [],
        displayedMonths: [],
        startDate: null,
        endDate: null,
        state: null
      },
      getJSON: function() {
        var json, _this;
        _this = this;
        json = {
          "availability": []
        };
        this.element.find('.' + this.options.boxClass.fullDay).each(function() {
          var elem;
          elem = $(this);
          json.availability.push({
            "date": elem.find('.' + _this.options.boxClass.am).attr('data-date'),
            "type": elem.find('.' + _this.options.boxClass.am).attr('data-status-type'),
            "delimiter": elem.find('.' + _this.options.boxClass.am).attr('data-delimiter')
          });
          return json.availability.push({
            "date": elem.find('.' + _this.options.boxClass.pm).attr('data-date'),
            "type": elem.find('.' + _this.options.boxClass.pm).attr('data-status-type'),
            "delimiter": elem.find('.' + _this.options.boxClass.pm).attr('data-delimiter')
          });
        });
        return JSON.stringify(json, null, '\t');
      },
      _trackable: function(timeOfDay) {
        return $.inArray(timeOfDay.attr('data-status-type'), this.options.dontTrackStates) === -1;
      },
      _track: function() {
        var _this;
        _this = this;
        return this.element.on({
          mousemove: function(event) {
            var amChild, hoverState, parent, pmChild;
            parent = $(this).find('div');
            amChild = $(this).find('.' + _this.options.boxClass.am);
            pmChild = $(this).find('.' + _this.options.boxClass.pm);
            if (_this._getLocation(this, event)) {
              if (!_this._highlightable()) {
                parent.removeClass(_this._getAllClasses(_this.options.hoverStates));
                hoverState = _this._getReverseType(amChild);
                return amChild.addClass(_this.options.hoverStates.am[hoverState]);
              } else {
                _this._eraseHighlights();
                return _this._trackHighlights(this, "T00:00:00");
              }
            } else {
              if (!_this._highlightable()) {
                parent.removeClass(_this._getAllClasses(_this.options.hoverStates));
                hoverState = _this._getReverseType(pmChild);
                return pmChild.addClass(_this.options.hoverStates.pm[hoverState]);
              } else {
                _this._eraseHighlights();
                return _this._trackHighlights(this, "T12:00:00");
              }
            }
          },
          mouseleave: function(event) {
            var parent;
            parent = $(this).find('div');
            return parent.removeClass(_this._getAllClasses(_this.options.hoverStates));
          },
          click: function(event) {
            var amChild, pmChild;
            amChild = $(this).find('.' + _this.options.boxClass.am);
            pmChild = $(this).find('.' + _this.options.boxClass.pm);
            if (_this._getLocation(this, event)) {
              if (_this._trackable(amChild)) {
                return _this._setDates(this, "T00:00:00");
              }
            } else {
              if (_this._trackable(pmChild)) {
                return _this._setDates(this, "T12:00:00");
              }
            }
          }
        }, "." + this.options.trackClass);
      },
      _getLocation: function(that, event) {
        var h, offset;
        offset = $(that).offset();
        h = $(that).height() + offset.top;
        return (h - event.pageY) > (event.pageX - offset.left);
      },
      _highlightable: function() {
        return this._options.startDate && !this._options.endDate;
      },
      _eraseHighlights: function() {
        return $("." + this.options.boxClass.am + ", ." + this.options.boxClass.pm).removeClass(this._getAllClasses(this.options.highlightStates));
      },
      _getReverseType: function(that) {
        return this.options.reverseTypes[$(that).attr('data-status-type')];
      },
      _trackHighlights: function(that, pos, highlightState) {
        var cursorPos, _this;
        _this = this;
        cursorPos = $(that).attr("data-date") + pos;
        return this.element.find("." + this.options.boxClass.fullDay).each(function() {
          var amChild, cursorAdj, each_box, pmChild;
          if (cursorPos < _this._options.startDate) {
            cursorAdj = $(that).attr("data-date") + "T00:00:00";
            each_box = $(this).attr("data-date") + "T00:00:00";
            if (_this._compareDates(each_box, cursorAdj, ">=") && _this._compareDates(each_box, _this._options.startDate, "<=")) {
              amChild = $(this).find('.' + _this.options.boxClass.am);
              pmChild = $(this).find('.' + _this.options.boxClass.pm);
              if (_this._compareDates(each_box, cursorAdj, "==") && ~cursorPos.indexOf("T12:00:00")) {
                if (_this._trackable(pmChild)) {
                  return pmChild.addClass(_this.options.highlightStates.pm[_this._options.state]);
                }
              } else if (_this._compareDates(each_box, _this._options.startDate, "==")) {
                if (_this._trackable(amChild)) {
                  return amChild.addClass(_this.options.highlightStates.am[_this._options.state]);
                }
              } else {
                if (_this._trackable(amChild)) {
                  amChild.addClass(_this.options.highlightStates.am[_this._options.state]);
                }
                if (_this._trackable(pmChild)) {
                  return pmChild.addClass(_this.options.highlightStates.pm[_this._options.state]);
                }
              }
            }
          } else if (cursorPos > _this._options.startDate) {
            cursorAdj = $(that).attr("data-date") + "T12:00:00";
            each_box = $(this).attr("data-date") + "T12:00:00";
            if (_this._compareDates(each_box, cursorAdj, "<=") && _this._compareDates(each_box, _this._options.startDate, ">=")) {
              amChild = $(this).find('.' + _this.options.boxClass.am);
              pmChild = $(this).find('.' + _this.options.boxClass.pm);
              if (_this._compareDates(each_box, cursorAdj, "==") && ~cursorPos.indexOf("T00:00:00")) {
                if (_this._trackable(amChild)) {
                  return $(this).find("." + _this.options.boxClass.am).addClass(_this.options.highlightStates.am[_this._options.state]);
                }
              } else if (_this._compareDates(each_box, _this._options.startDate, "==")) {
                if (_this._trackable(pmChild)) {
                  return $(this).find("." + _this.options.boxClass.pm).addClass(_this.options.highlightStates.pm[_this._options.state]);
                }
              } else {
                if (_this._trackable(amChild)) {
                  $(this).find("." + _this.options.boxClass.am).addClass(_this.options.highlightStates.am[_this._options.state]);
                }
                if (_this._trackable(pmChild)) {
                  return $(this).find("." + _this.options.boxClass.pm).addClass(_this.options.highlightStates.pm[_this._options.state]);
                }
              }
            }
          } else if (cursorPos === _this._options.startDate) {
            amChild = $(this).find('.' + _this.options.boxClass.am);
            pmChild = $(this).find('.' + _this.options.boxClass.pm);
            each_box = $(this).attr("data-date") + "T00:00:00";
            if (_this._compareDates(each_box, cursorPos, "==")) {
              if (_this._trackable(amChild)) {
                $(this).find("." + _this.options.boxClass.am).addClass(_this.options.highlightStates.am[_this._options.state]);
              }
            }
            each_box = $(this).attr("data-date") + "T12:00:00";
            if (_this._compareDates(each_box, cursorPos, "==")) {
              if (_this._trackable(pmChild)) {
                return $(this).find("." + _this.options.boxClass.pm).addClass(_this.options.highlightStates.pm[_this._options.state]);
              }
            }
          }
        });
      },
      _setDates: function(that, pos) {
        var data, _this;
        _this = this;
        switch (this.options.mode) {
          case "datePicker":
            data = {
              elem: that,
              date: $(that).attr("data-date") + pos,
              parentElem: this.element,
              inputElem: this.inputElem
            };
            return this._trigger("datePicked", 0, data);
          default:
            if (this._options.startDate && this._options.endDate) {
              this._options.startDate = this._options.endDate = this._options.state = null;
            }
            if (this._options.startDate) {
              this._options.endDate = $(that).attr("data-date") + pos;
              this._trigger("endDateSet", 0, this._options.endDate);
              if (this._compareDates(this._options.startDate, this._options.endDate, "<")) {
                this.element.find("." + this.options.boxClass.fullDay).each(function() {
                  var amChild, pmChild;
                  amChild = $(this).find('.' + _this.options.boxClass.am);
                  pmChild = $(this).find('.' + _this.options.boxClass.pm);
                  if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T12:00:00", "<") && _this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T00:00:00", ">")) {
                    if (_this._trackable(amChild)) {
                      amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am[_this._options.state]).attr('data-status-type', _this._options.state);
                    }
                    if (_this._trackable(pmChild)) {
                      return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm[_this._options.state]).attr('data-status-type', _this._options.state);
                    }
                  } else if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T12:00:00", "==")) {
                    if (_this._trackable(pmChild)) {
                      return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]).attr('data-status-type', _this._options.state).attr('data-delimiter', 'true');
                    }
                  } else if (_this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T00:00:00", "==")) {
                    if (_this._trackable(amChild)) {
                      return amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]).attr('data-status-type', _this._options.state).attr('data-delimiter', 'true');
                    }
                  }
                });
                this._eraseHighlights();
                return true;
              } else if (this._compareDates(this._options.startDate, this._options.endDate, ">")) {
                this.element.find("." + this.options.boxClass.fullDay).each(function() {
                  var amChild, pmChild;
                  amChild = $(this).find('.' + _this.options.boxClass.am);
                  pmChild = $(this).find('.' + _this.options.boxClass.pm);
                  if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T00:00:00", ">") && _this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T12:00:00", "<")) {
                    if (_this._trackable(amChild)) {
                      amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am[_this._options.state]).attr('data-status-type', _this._options.state);
                    }
                    if (_this._trackable(pmChild)) {
                      return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm[_this._options.state]).attr('data-status-type', _this._options.state);
                    }
                  } else if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T00:00:00", "==")) {
                    if (_this._trackable(amChild)) {
                      return amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]).attr('data-status-type', _this._options.state).attr('data-delimiter', 'true');
                    }
                  } else if (_this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T12:00:00", "==")) {
                    if (_this._trackable(pmChild)) {
                      return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]).attr('data-status-type', _this._options.state).attr('data-delimiter', 'true');
                    }
                  }
                });
                this._eraseHighlights();
                return true;
              } else {
                this.element.find("." + this.options.boxClass.fullDay).each(function() {
                  var amChild, pmChild;
                  amChild = $(this).find('.' + _this.options.boxClass.am);
                  pmChild = $(this).find('.' + _this.options.boxClass.pm);
                  if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T00:00:00", "==")) {
                    if (_this._trackable(amChild)) {
                      return amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]).attr('data-status-type', _this._options.state).attr('data-delimiter', 'true');
                    }
                  } else if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T12:00:00", "==")) {
                    if (_this._trackable(pmChild)) {
                      return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]).attr('data-status-type', _this._options.state).attr('data-delimiter', 'true');
                    }
                  }
                });
                return true;
              }
            } else {
              this._options.startDate = $(that).attr("data-date") + pos;
              this._options.state = pos === "T00:00:00" ? _this._getReverseType($(that).find('.' + _this.options.boxClass.am)) : _this._getReverseType($(that).find('.' + _this.options.boxClass.pm));
              this._trigger("startDateSet", 0, this._options.startDate);
              return false;
            }
        }
      },
      _getAllClasses: function(obj) {
        var results, _this;
        _this = this;
        results = "";
        $.each(obj, function(index, value) {
          if (obj[index] instanceof Object) {
            return results += _this._getAllClasses(obj[index]);
          } else {
            return results += value + " ";
          }
        });
        return results;
      },
      _toDate: function(date) {
        return new Date(date);
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
        return new Date(year, month + 1, 0).getDate();
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
        var blanks, daycount, dayshtml, fulldate, i, states, status, _i, _len, _ref;
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
        states = {};
        i = 0;
        while (i < this._getDaysInMonth(year, month)) {
          states = {
            am: {
              type: this.options.defaultStatusType,
              delimiter: "false"
            },
            pm: {
              type: this.options.defaultStatusType,
              delimiter: "false"
            }
          };
          fulldate = "" + year + "-" + (this._pad(parseInt(month) + 1, 2)) + "-" + (this._pad(i + 1, 2));
          if (this._options.loadedData.availability != null) {
            _ref = this._options.loadedData.availability;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              status = _ref[_i];
              if (status.date === fulldate + "T00:00:00") {
                states.am.type = status.type;
                states.am.delimiter = status.delimiter;
              } else if (status.date === fulldate + "T12:00:00") {
                states.pm.type = status.type;
                states.pm.delimiter = status.delimiter;
              }
            }
          }
          dayshtml += "<div class=\"" + this.options.boxClass.fullDay + " " + this.options.trackClass + "\" data-date=\"" + fulldate + "\">\n  <div class=\"" + this.options.boxClass.am + " " + this.options.setStates.am[states.am.type] + " " + (states.am.delimiter === "true" ? this.options.setStates.am.delimiter : "") + "\" data-date=\"" + fulldate + "T00:00:00\" data-status-type=\"" + states.am.type + "\" data-delimiter=\"" + states.am.delimiter + "\">\n    <div class=\"" + this.options.boxClass.pm + " " + this.options.setStates.pm[states.pm.type] + " " + (states.pm.delimiter === "true" ? this.options.setStates.pm.delimiter : "") + "\" data-date=\"" + fulldate + "T12:00:00\" data-status-type=\"" + states.pm.type + "\" data-delimiter=\"" + states.pm.delimiter + "\">\n      " + (i + 1) + "\n    </div>\n  </div>\n</div>";
          daycount++;
          i++;
        }
        while (daycount < 42) {
          dayshtml += "<div class=\"empty_day_box\"></div>";
          daycount++;
        }
        return dayshtml;
      },
      _placePopup: function(base, elem) {
        var botCalPos, botPlace, currView, elemHeight, topCalPos, topPlace;
        currView = new Array();
        currView['top'] = $(window).scrollTop();
        currView['bot'] = $(window).height() + currView['top'];
        elemHeight = elem.outerHeight(true);
        botPlace = base.offset().top + base.outerHeight(true);
        topPlace = base.offset().top - elemHeight;
        botCalPos = botPlace + elemHeight;
        topCalPos = base.offset().top - elemHeight;
        if ((botCalPos <= currView['bot']) || (topCalPos < currView['top'])) {
          return elem.css({
            top: botPlace + "px",
            left: base.offset().left + "px"
          });
        } else {
          return elem.css({
            top: topPlace + "px",
            left: base.offset().left + "px"
          });
        }
      },
      _pad: function(num, places) {
        var zero;
        zero = places - num.toString().length + 1;
        return Array(+(zero > 0 && zero)).join("0") + num;
      },
      _getMonth: function(year, month) {
        var nth;
        this._setLoadedMonths(year, month);
        if (this._options.displayedMonths.length < this.options.period) {
          this._setDisplayedMonths(year, month);
        }
        nth = this._options.loadedMonths.length % this.options.nthMonth;
        return "<div class=\"month_box " + (nth === 0 ? this.options.nthMonthClass : "") + "\">\n  <div class=\"month_header\">" + this.options.monthFullName[month] + " " + year + "</div>\n  " + (this._getWeekdaysHtml()) + "\n  " + (this._getDaysHtml(year, month)) + "\n</div>";
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
      _getCalendar: function(wrapperStart, wrapperEnd) {
        var calendarhtml, i, month, year;
        this._trigger("beforebuild");
        calendarhtml = "";
        if (typeof wrapperStart !== "undefined") {
          calendarhtml += wrapperStart;
        }
        calendarhtml += this.options.prevPeriodHtml();
        if (this.options.scrollDirection === "horizontal") {
          calendarhtml += this.options.nextPeriodHtml();
        }
        calendarhtml += "<div class=\"period_box clearfix\">\n  <div class=\"slider_container clearfix\">";
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
        if (this.options.scrollDirection === "vertical") {
          calendarhtml += this.options.nextPeriodHtml();
        }
        if (typeof wrapperEnd !== "undefined") {
          calendarhtml += wrapperEnd;
        }
        return calendarhtml;
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
      _getPrevMonths: function(period) {
        var animatemargin, cols, colwidth, currentpos, date, html, rowheight, rows;
        if (!this.element.find('.slider_container').is(':animated')) {
          switch (this.options.scrollDirection) {
            case "vertical":
              currentpos = parseFloat(this.element.find('.slider_container').css('marginTop'));
              rowheight = this.element.find('.month_box').outerHeight(true);
              rows = period / this.options.monthScrollPeriod;
              animatemargin = currentpos + (rowheight * rows);
              animatemargin = animatemargin === (rowheight * rows) || animatemargin > 0 ? 0 : animatemargin;
              date = this._splitDate(0, this._options.displayedMonths);
              html = this._getMonthsByPeriod(date[0], date[1], -period);
              if (html.length > 0) {
                return this.element.find('.slider_container').prepend(html).css({
                  "marginTop": -(rowheight * rows) + "px"
                }).animate({
                  marginTop: animatemargin + "px"
                }, this.options.animateSpeed);
              } else {
                return this.element.find('.slider_container').animate({
                  marginTop: animatemargin + "px"
                }, this.options.animateSpeed);
              }
              break;
            default:
              currentpos = parseFloat(this.element.find('.slider_container').css('marginLeft'));
              colwidth = this.element.find('.month_box').outerWidth(true);
              cols = period / this.options.monthScrollPeriod;
              animatemargin = currentpos + (colwidth * cols);
              animatemargin = animatemargin === (colwidth * cols) || animatemargin > 0 ? 0 : animatemargin;
              date = this._splitDate(0, this._options.displayedMonths);
              html = this._getMonthsByPeriod(date[0], date[1], -period);
              if (html.length > 0) {
                return this.element.find('.slider_container').prepend(html).css({
                  "marginLeft": -(colwidth * cols) + "px"
                }).animate({
                  marginLeft: animatemargin + "px"
                }, this.options.animateSpeed);
              } else {
                return this.element.find('.slider_container').animate({
                  marginLeft: animatemargin + "px"
                }, this.options.animateSpeed);
              }
          }
        }
      },
      _getNextMonths: function(period) {
        var animatemargin, cols, colwidth, currentpos, date, rowheight, rows;
        if (!this.element.find('.slider_container').is(':animated')) {
          switch (this.options.scrollDirection) {
            case "vertical":
              currentpos = parseFloat(this.element.find('.slider_container').css('marginTop'));
              rowheight = this.element.find('.month_box').outerHeight(true);
              rows = period / this.options.monthScrollPeriod;
              animatemargin = currentpos - (rowheight * rows);
              date = this._splitDate(this._options.displayedMonths.length - 1, this._options.displayedMonths);
              return this.element.find('.slider_container').append(this._getMonthsByPeriod(date[0], date[1], period)).animate({
                marginTop: animatemargin + "px"
              }, this.options.animateSpeed);
            default:
              currentpos = parseFloat(this.element.find('.slider_container').css('marginLeft'));
              colwidth = this.element.find('.month_box').outerWidth(true);
              cols = period / this.options.monthScrollPeriod;
              animatemargin = currentpos - (colwidth * cols);
              date = this._splitDate(this._options.displayedMonths.length - 1, this._options.displayedMonths);
              return this.element.find('.slider_container').append(this._getMonthsByPeriod(date[0], date[1], period)).animate({
                marginLeft: animatemargin + "px"
              }, this.options.animateSpeed);
          }
        }
      },
      _startup: function() {
        var _this = this;
        switch (this.options.mode) {
          case "datePicker":
            this.inputElem = $.extend({}, this.element);
            this.inputElem.after(this._getCalendar("<div class=\"bearcal-wrapper " + this.options.appendClass + "\">", "</div>")).next().hide();
            this.element = $.extend({}, this.inputElem.next('.bearcal-wrapper'));
            this.inputElem.on("focus", function() {
              $('.bearcal-wrapper').fadeOut('fast');
              _this._placePopup(_this.inputElem, _this.element);
              return _this.element.fadeIn('fast');
            });
            $(document).off("click.a07").on("click.a07", function(event) {
              if ($('.bearcal-wrapper').is(':visible')) {
                if (($(event.target).attr('class') !== 'bearcal-wrapper') && ($(event.target).parents('.bearcal-wrapper').length === 0) && ($.inArray($(event.target).get(0), $.a07.BearCal.getDOMInstances()) < 0)) {
                  return $('.bearcal-wrapper').fadeOut('fast');
                }
              }
            });
            break;
          default:
            this.element.append(this._getCalendar());
        }
        this.element.find('.prev_months').click(function() {
          _this._getPrevMonths(_this.options.monthScrollPeriod);
          return false;
        });
        this.element.find('.next_months').click(function() {
          _this._getNextMonths(_this.options.monthScrollPeriod);
          return false;
        });
        this.element.find('.prev_year').click(function() {
          _this._getPrevMonths(_this.options.yearScrollPeriod);
          return false;
        });
        this.element.find('.next_year').click(function() {
          _this._getNextMonths(_this.options.yearScrollPeriod);
          return false;
        });
        return this._track();
      },
      _create: function() {
        var _this;
        $.a07.BearCal.instances.push(this.element);
        _this = this;
        this._options = $.extend(true, {}, this._options);
        if (this.options.json) {
          return $.getJSON(this.options.jsonUrl, function(data) {
            $.extend(_this._options.loadedData, data);
            return _this._startup();
          });
        } else {
          return _this._startup();
        }
      },
      _init: function() {
        return this._setDate();
      },
      destroy: function() {},
      _setOption: function(key, value) {}
    });
    return $.extend($.a07.BearCal, {
      instances: [],
      getDOMInstances: function() {
        var t;
        t = [];
        $.each(this.instances, function(i, v) {
          return t.push(v.get(0));
        });
        return t;
      }
    });
  })(jQuery, window, document);

}).call(this);
