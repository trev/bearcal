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
        boxClass: {
          am: "am_box",
          pm: "pm_box",
          fullDay: "day_box"
        },
        track: true,
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
        json: {
          enable: false,
          type: "all",
          url: ""
        },
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
          var amElem, pmElem;
          amElem = $(this).find('.' + _this.options.boxClass.am);
          pmElem = $(this).find('.' + _this.options.boxClass.pm);
          json.availability.push({
            "date": amElem.attr('data-date'),
            "type": amElem.attr('data-status-type'),
            "delimiter": amElem.attr('data-delimiter'),
            "place": amElem.attr('data-range-place')
          });
          return json.availability.push({
            "date": pmElem.attr('data-date'),
            "type": pmElem.attr('data-status-type'),
            "delimiter": pmElem.attr('data-delimiter'),
            "place": pmElem.attr('data-range-place')
          });
        });
        return JSON.stringify(json, null, '\t');
      },
      setLiveDates: function(dates, range) {
        var _this;
        if (range == null) {
          range = false;
        }
        _this = this;
        if (range === true) {
          dates = this._prepareRange(dates);
        }
        return $.each(dates.availability, function(index, value) {
          var matchedElement, tod;
          _this._options.loadedData.availability.push(value);
          matchedElement = _this.element.find("." + _this.options.boxClass.fullDay + " div[data-date='" + value.date + "']");
          if (matchedElement.length === 1) {
            tod = value.date.slice(10, 19) === "T00:00:00" ? "am" : "pm";
            matchedElement.attr({
              dataStatusType: value.type,
              dataDelimiter: value.delimiter,
              dataPlace: value.place
            });
            return matchedElement.addClass(_this.options.setStates[tod][value.type] + " " + (value.delimiter === "true" ? _this.options.setStates[tod].delimiter : ""));
          }
        });
      },
      _getLastIndex: function(arr, needle) {
        var idx, indices;
        idx = $.inArray(needle, arr);
        indices = [];
        while (idx !== -1) {
          indices.push(idx);
          idx = $.inArray(needle, arr, idx + 1);
        }
        return indices[indices.length - 1];
      },
      getJSONByStates: function(states, range) {
        var json, nextArrayIndex, nextStatusType, _this;
        if (range == null) {
          range = false;
        }
        _this = this;
        nextStatusType = [];
        nextArrayIndex = [];
        json = {
          "availability": []
        };
        while (this.element.find('.' + this.options.boxClass.fullDay + ' .' + this.options.boxClass.am).eq(0).attr('data-range-place') === 'in-between') {
          this._loadPrevMonths(this.options.monthScrollPeriod);
        }
        while (this.element.find('.' + this.options.boxClass.fullDay + ' .' + this.options.boxClass.pm).reverse().eq(0).attr('data-range-place') === 'in-between') {
          this._loadNextMonths(this.options.monthScrollPeriod);
        }
        this.element.find('.' + this.options.boxClass.fullDay).each(function() {
          var amElem, lastIndex, pmElem, pushPosition, workingIndex;
          amElem = $(this).find('.' + _this.options.boxClass.am);
          pmElem = $(this).find('.' + _this.options.boxClass.pm);
          if ($.inArray(amElem.attr('data-status-type'), states) !== -1) {
            if ((range && $.inArray(amElem.attr('data-range-place'), ['start', 'end', 'start-end']) !== -1) || (!range)) {
              workingIndex = $.inArray(amElem.attr('data-status-type'), nextStatusType);
              if (workingIndex !== -1 && amElem.attr('data-range-place') === 'end') {
                lastIndex = _this._getLastIndex(nextStatusType, amElem.attr('data-status-type'));
                pushPosition = nextArrayIndex[lastIndex];
                json.availability[pushPosition] = {
                  "date": amElem.attr('data-date'),
                  "type": amElem.attr('data-status-type'),
                  "delimiter": amElem.attr('data-delimiter'),
                  "place": amElem.attr('data-range-place')
                };
                nextArrayIndex.splice(lastIndex, 1);
                nextStatusType.splice(lastIndex, 1);
              } else {
                json.availability.push({
                  "date": amElem.attr('data-date'),
                  "type": amElem.attr('data-status-type'),
                  "delimiter": amElem.attr('data-delimiter'),
                  "place": amElem.attr('data-range-place')
                });
              }
              if (amElem.attr('data-range-place') !== 'start-end' && amElem.attr('data-range-place') !== 'end') {
                nextArrayIndex.push(json.availability.push(null) - 1);
                nextStatusType.push(amElem.attr('data-status-type'));
              }
            }
          }
          if ($.inArray(pmElem.attr('data-status-type'), states) !== -1) {
            if ((range && $.inArray(pmElem.attr('data-range-place'), ['start', 'end', 'start-end']) !== -1) || (!range)) {
              workingIndex = $.inArray(pmElem.attr('data-status-type'), nextStatusType);
              if (workingIndex !== -1 && pmElem.attr('data-range-place') === 'end') {
                lastIndex = _this._getLastIndex(nextStatusType, pmElem.attr('data-status-type'));
                pushPosition = nextArrayIndex[lastIndex];
                json.availability[pushPosition] = {
                  "date": pmElem.attr('data-date'),
                  "type": pmElem.attr('data-status-type'),
                  "delimiter": pmElem.attr('data-delimiter'),
                  "place": pmElem.attr('data-range-place')
                };
                nextArrayIndex.splice(lastIndex, 1);
                nextStatusType.splice(lastIndex, 1);
              } else {
                json.availability.push({
                  "date": pmElem.attr('data-date'),
                  "type": pmElem.attr('data-status-type'),
                  "delimiter": pmElem.attr('data-delimiter'),
                  "place": pmElem.attr('data-range-place')
                });
              }
              if (pmElem.attr('data-range-place') !== 'start-end' && pmElem.attr('data-range-place') !== 'end') {
                nextArrayIndex.push(json.availability.push(null) - 1);
                return nextStatusType.push(pmElem.attr('data-status-type'));
              }
            }
          }
        });
        return JSON.stringify(json, null, '\t');
      },
      _compareDates: function(s_date, e_date, operator) {
        s_date = this._parseDate(s_date);
        e_date = this._parseDate(e_date);
        switch (operator) {
          case "<":
            return new Date(s_date).getTime() < new Date(e_date).getTime();
          case ">":
            return new Date(s_date).getTime() > new Date(e_date).getTime();
          case ">=":
            return new Date(s_date).getTime() >= new Date(e_date).getTime();
          case "<=":
            return new Date(s_date).getTime() <= new Date(e_date).getTime();
          case "==":
            return new Date(s_date).getTime() === new Date(e_date).getTime();
        }
      },
      _parseDate: function(d) {
        var day, month, months, time, year;
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        year = d.slice(0, 4);
        month = months[d.slice(5, 7) - 1];
        day = d.slice(8, 10);
        time = d.slice(-8, d.length);
        return "" + month + " " + day + ", " + year + " " + time;
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
      _startRangeLogic: function(domElement, defaultPlace) {
        var oToken, prevDate;
        if (defaultPlace == null) {
          defaultPlace = 'start';
        }
        oToken = false;
        prevDate = this._getPrevDateDOMObj(domElement.attr('data-date'));
        if (domElement.attr('data-range-place') === '') {
          domElement.attr('data-range-place', defaultPlace);
          oToken = true;
        }
        if (this._options.state === domElement.attr('data-status-type')) {
          domElement.attr('data-range-place', 'in-between');
        } else {
          if (domElement.attr('data-range-place') === 'in-between') {
            if (prevDate.attr('data-range-place') === 'in-between') {
              prevDate.attr('data-range-place', 'end');
            }
            if (prevDate.attr('data-range-place') === 'start') {
              prevDate.attr('data-range-place', 'start-end');
            }
            if (prevDate.attr('data-status-type') === 'booked') {
              this._spreadRangeLogic(domElement, 'reverse');
            }
          }
        }
        if (this._options.state === this.options.defaultStatusType) {
          domElement.attr('data-range-place', '');
        }
        return oToken;
      },
      _endRangeLogic: function(domElement, defaultPlace) {
        var nextDate, oToken;
        if (defaultPlace == null) {
          defaultPlace = 'end';
        }
        oToken = false;
        nextDate = this._getNextDateDOMObj(domElement.attr('data-date'));
        if (domElement.attr('data-range-place') === '') {
          domElement.attr('data-range-place', defaultPlace);
          oToken = true;
        }
        if (this._options.state === domElement.attr('data-status-type')) {
          domElement.attr('data-range-place', 'in-between');
        } else {
          if (domElement.attr('data-range-place') === 'in-between') {
            if (nextDate.attr('data-range-place') === 'in-between') {
              nextDate.attr('data-range-place', 'start');
            }
            if (nextDate.attr('data-range-place') === 'end') {
              nextDate.attr('data-range-place', 'start-end');
            }
            if (nextDate.attr('data-status-type') === 'booked') {
              this._spreadRangeLogic(domElement);
            }
          }
        }
        if (this._options.state === this.options.defaultStatusType) {
          domElement.attr('data-range-place', '');
        }
        return oToken;
      },
      _startEndRangeLogic: function(domElement, defaultPlace) {
        var nextDate, oToken, prevDate, _this;
        if (defaultPlace == null) {
          defaultPlace = 'start-end';
        }
        oToken = false;
        _this = this;
        nextDate = this._getNextDateDOMObj(domElement.attr('data-date'));
        prevDate = this._getPrevDateDOMObj(domElement.attr('data-date'));
        if (domElement.attr('data-range-place') === '') {
          domElement.attr('data-range-place', defaultPlace);
          oToken = true;
        } else {
          if (domElement.attr('data-range-place') === 'start') {
            if (nextDate.attr('data-range-place') === 'in-between') {
              nextDate.attr('data-range-place', 'start');
            }
            if (nextDate.attr('data-range-place') === 'end') {
              nextDate.attr('data-range-place', 'start-end');
            }
            if (nextDate.attr('data-status-type') === 'booked') {
              this._spreadRangeLogic(domElement);
            }
          }
          if (domElement.attr('data-range-place') === 'in-between') {
            if (nextDate.attr('data-range-place') === 'in-between') {
              nextDate.attr('data-range-place', 'start');
            }
            if (nextDate.attr('data-range-place') === 'end') {
              nextDate.attr('data-range-place', 'start-end');
            }
            if (nextDate.attr('data-status-type') === 'booked') {
              this._spreadRangeLogic(domElement);
            }
            if (prevDate.attr('data-range-place') === 'in-between') {
              prevDate.attr('data-range-place', 'end');
            }
            if (prevDate.attr('data-range-place') === 'start') {
              prevDate.attr('data-range-place', 'start-end');
            }
            if (prevDate.attr('data-status-type') === 'booked') {
              this._spreadRangeLogic(domElement, 'reverse');
            }
          }
          if (domElement.attr('data-range-place') === 'end') {
            if (prevDate.attr('data-range-place') === 'in-between') {
              prevDate.attr('data-range-place', 'end');
            }
            if (prevDate.attr('data-range-place') === 'start') {
              prevDate.attr('data-range-place', 'start-end');
            }
            if (prevDate.attr('data-status-type') === 'booked') {
              this._spreadRangeLogic(domElement, 'reverse');
            }
          }
          if (this._options.state === this.options.defaultStatusType) {
            domElement.attr('data-range-place', '');
          }
        }
        return oToken;
      },
      _spreadRangeLogic: function(domElement, direction) {
        var domElementDate, domElementType, found, _this;
        if (direction == null) {
          direction = "forward";
        }
        _this = this;
        domElementDate = domElement.attr('data-date');
        domElementType = domElement.attr('data-status-type');
        found = false;
        if (direction === 'forward') {
          this.element.find("." + this.options.boxClass.fullDay).each(function() {
            var amChild, pmChild;
            amChild = $(this).find('.' + _this.options.boxClass.am);
            pmChild = $(this).find('.' + _this.options.boxClass.pm);
            if ((_this._compareDates(amChild.attr('data-date'), domElementDate, '>')) && (amChild.attr('data-status-type') === domElementType) && (found !== true)) {
              if (amChild.attr('data-range-place') === 'in-between') {
                amChild.attr('data-range-place', 'start');
              }
              if (amChild.attr('data-range-place') === 'end') {
                amChild.attr('data-range-place', 'start-end');
              }
              found = true;
            }
            if ((_this._compareDates(pmChild.attr('data-date'), domElementDate, '>')) && (pmChild.attr('data-status-type') === domElementType) && (found !== true)) {
              if (pmChild.attr('data-range-place') === 'in-between') {
                pmChild.attr('data-range-place', 'start');
              }
              if (pmChild.attr('data-range-place') === 'end') {
                pmChild.attr('data-range-place', 'start-end');
              }
              return found = true;
            }
          });
        }
        if (direction === 'reverse') {
          return this.element.find("." + this.options.boxClass.fullDay).reverse().each(function() {
            var amChild, pmChild;
            amChild = $(this).find('.' + _this.options.boxClass.am);
            pmChild = $(this).find('.' + _this.options.boxClass.pm);
            if ((_this._compareDates(pmChild.attr('data-date'), domElementDate, '<')) && (pmChild.attr('data-status-type') === domElementType) && (found !== true)) {
              if (pmChild.attr('data-range-place') === 'in-between') {
                pmChild.attr('data-range-place', 'end');
              }
              if (pmChild.attr('data-range-place') === 'start') {
                pmChild.attr('data-range-place', 'start-end');
              }
              found = true;
            }
            if ((_this._compareDates(amChild.attr('data-date'), domElementDate, '<')) && (amChild.attr('data-status-type') === domElementType) && (found !== true)) {
              if (amChild.attr('data-range-place') === 'in-between') {
                amChild.attr('data-range-place', 'end');
              }
              if (amChild.attr('data-range-place') === 'start') {
                amChild.attr('data-range-place', 'start-end');
              }
              return found = true;
            }
          });
        }
      },
      _setDates: function(that, pos) {
        var data, startPos, _this;
        _this = this;
        if (this.options.mode === "datePicker") {
          data = {
            elem: that,
            date: $(that).attr("data-date") + pos,
            parentElem: this.element,
            inputElem: this.inputElem
          };
          return this._trigger("datePicked", 0, data);
        } else {
          if (this._options.startDate && this._options.endDate) {
            this._options.startDate = this._options.endDate = this._options.state = null;
          }
          if (this._options.startDate) {
            this._options.endDate = $(that).attr("data-date") + pos;
            this._trigger("endDateSet", 0, this._options.endDate);
            startPos = _this._options.startDate.slice(10, 19);
            if (this._compareDates(this._options.startDate, this._options.endDate, "<")) {
              this.element.find("." + this.options.boxClass.fullDay).each(function() {
                var amChild, amOToken, pmChild, pmOToken;
                amChild = $(this).find('.' + _this.options.boxClass.am);
                pmChild = $(this).find('.' + _this.options.boxClass.pm);
                if (_this._compareDates(_this._options.startDate, $(this).attr('data-date') + startPos, '==')) {
                  if (startPos === "T00:00:00") {
                    amOToken = _this._startRangeLogic(amChild);
                  } else {
                    pmOToken = _this._startRangeLogic(pmChild);
                  }
                }
                if (_this._compareDates(_this._options.endDate, $(this).attr('data-date') + pos, '==')) {
                  if (pos === "T00:00:00") {
                    amOToken = _this._endRangeLogic(amChild);
                  } else {
                    pmOToken = _this._endRangeLogic(pmChild);
                  }
                }
                if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T12:00:00", "<") && _this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T00:00:00", ">")) {
                  if (_this._trackable(amChild)) {
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': "false"
                    });
                    if (_this._options.state === _this.options.defaultStatusType) {
                      amChild.attr('data-range-place', '');
                    } else {
                      if (!amOToken) {
                        amChild.attr('data-range-place', 'in-between');
                      }
                    }
                  }
                  if (_this._trackable(pmChild)) {
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': "false"
                    });
                    if (_this._options.state === _this.options.defaultStatusType) {
                      return pmChild.attr('data-range-place', '');
                    } else {
                      if (!pmOToken) {
                        return pmChild.attr('data-range-place', 'in-between');
                      }
                    }
                  }
                } else if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T12:00:00", "==")) {
                  if (_this._trackable(pmChild)) {
                    return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'true'
                    });
                  }
                } else if (_this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T00:00:00", "==")) {
                  if (_this._trackable(amChild)) {
                    return amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'true'
                    });
                  }
                }
              });
              this._eraseHighlights();
              return true;
            } else if (this._compareDates(this._options.startDate, this._options.endDate, ">")) {
              this.element.find("." + this.options.boxClass.fullDay).each(function() {
                var amChild, amOToken, pmChild, pmOToken;
                amChild = $(this).find('.' + _this.options.boxClass.am);
                pmChild = $(this).find('.' + _this.options.boxClass.pm);
                if (_this._compareDates(_this._options.endDate, $(this).attr('data-date') + pos, '==')) {
                  if (pos === "T00:00:00") {
                    amOToken = _this._startRangeLogic(amChild, 'start');
                  } else {
                    pmOToken = _this._startRangeLogic(pmChild, 'start');
                  }
                }
                if (_this._compareDates(_this._options.startDate, $(this).attr('data-date') + startPos, '==')) {
                  if (startPos === "T00:00:00") {
                    amOToken = _this._endRangeLogic(amChild, 'end');
                  } else {
                    pmOToken = _this._endRangeLogic(pmChild, 'end');
                  }
                }
                if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T00:00:00", ">") && _this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T12:00:00", "<")) {
                  if (_this._trackable(amChild)) {
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'false'
                    });
                    if (!amOToken) {
                      amChild.attr('data-range-place', 'in-between');
                    }
                  }
                  if (_this._trackable(pmChild)) {
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'false'
                    });
                    if (!pmOToken) {
                      return pmChild.attr('data-range-place', 'in-between');
                    }
                  }
                } else if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T00:00:00", "==")) {
                  if (_this._trackable(amChild)) {
                    return amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'true'
                    });
                  }
                } else if (_this._compareDates(_this._options.endDate, $(this).attr("data-date") + "T12:00:00", "==")) {
                  if (_this._trackable(pmChild)) {
                    return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'true'
                    });
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
                if (_this._compareDates(_this._options.startDate, $(this).attr('data-date') + startPos, '==')) {
                  if (startPos === "T00:00:00") {
                    _this._startEndRangeLogic(amChild);
                  } else {
                    _this._startEndRangeLogic(pmChild);
                  }
                }
                if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T00:00:00", "==")) {
                  if (_this._trackable(amChild)) {
                    return amChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'true'
                    });
                  }
                } else if (_this._compareDates(_this._options.startDate, $(this).attr("data-date") + "T12:00:00", "==")) {
                  if (_this._trackable(pmChild)) {
                    return pmChild.removeClass(_this._getAllClasses(_this.options.setStates)).addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]).attr({
                      'data-status-type': _this._options.state,
                      'data-delimiter': 'true'
                    });
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
              delimiter: "false",
              place: ""
            },
            pm: {
              type: this.options.defaultStatusType,
              delimiter: "false",
              place: ""
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
                states.am.place = typeof status.place !== "undefined" ? status.place : "";
              } else if (status.date === fulldate + "T12:00:00") {
                states.pm.type = status.type;
                states.pm.delimiter = status.delimiter;
                states.pm.place = typeof status.place !== "undefined" ? status.place : "";
              }
            }
          }
          dayshtml += "<div class=\"" + this.options.boxClass.fullDay + " " + this.options.trackClass + "\" data-date=\"" + fulldate + "\">\n  <div class=\"" + this.options.boxClass.am + " " + this.options.setStates.am[states.am.type] + " " + (states.am.delimiter === "true" ? this.options.setStates.am.delimiter : "") + "\" data-date=\"" + fulldate + "T00:00:00\" data-status-type=\"" + states.am.type + "\" data-delimiter=\"" + states.am.delimiter + "\" data-range-place=\"" + states.am.place + "\">\n    <div class=\"" + this.options.boxClass.pm + " " + this.options.setStates.pm[states.pm.type] + " " + (states.pm.delimiter === "true" ? this.options.setStates.pm.delimiter : "") + "\" data-date=\"" + fulldate + "T12:00:00\" data-status-type=\"" + states.pm.type + "\" data-delimiter=\"" + states.pm.delimiter + "\" data-range-place=\"" + states.pm.place + "\">\n      " + (i + 1) + "\n    </div>\n  </div>\n</div>";
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
        var baseLeftOffset, baseTopOffset, botCalPos, botPlace, currView, elemHeight, topCalPos, topPlace;
        currView = new Array();
        currView['top'] = $(window).scrollTop();
        currView['bot'] = $(window).height() + currView['top'];
        elemHeight = elem.outerHeight(true);
        baseTopOffset = base.offset().top - base.offsetParent().offset().top;
        baseLeftOffset = base.offset().left - base.offsetParent().offset().left;
        botPlace = baseTopOffset + base.outerHeight(true);
        topPlace = baseTopOffset - elemHeight;
        botCalPos = botPlace + elemHeight;
        topCalPos = baseTopOffset - elemHeight;
        if ((botCalPos <= currView['bot']) || (topCalPos < currView['top'])) {
          return elem.css({
            top: botPlace + "px",
            left: baseLeftOffset + "px"
          });
        } else {
          return elem.css({
            top: topPlace + "px",
            left: baseLeftOffset + "px"
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
        return this._options.loadedMonths.push(year + "-" + month);
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
      _getMonthsByPeriod: function(year, month, period, display) {
        var date, html, i, movement, result, results, tmp, _i, _len, _month;
        if (display == null) {
          display = true;
        }
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
          if (display) {
            this._setDisplayedMonths(date[0], date[1], movement);
          }
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
      _loadPrevMonths: function(period) {
        var cols, colwidth, currentpos, date, html, rowheight, rows;
        switch (this.options.scrollDirection) {
          case "vertical":
            currentpos = this._parseMargin(this.element.find('.slider_container').css('marginTop'));
            rowheight = this.element.find('.month_box').outerHeight(true);
            rows = period / this.options.monthScrollPeriod;
            date = this._splitDate(0, this._options.loadedMonths);
            html = this._getMonthsByPeriod(date[0], date[1], -period, false);
            if (html.length > 0) {
              return this.element.find('.slider_container').prepend(html).css({
                "marginTop": -(rowheight * rows) + "px"
              });
            }
            break;
          default:
            currentpos = this._parseMargin(this.element.find('.slider_container').css('marginLeft'));
            colwidth = this.element.find('.month_box').outerWidth(true);
            cols = period / this.options.monthScrollPeriod;
            date = this._splitDate(0, this._options.loadedMonths);
            html = this._getMonthsByPeriod(date[0], date[1], -period, false);
            if (html.length > 0) {
              return this.element.find('.slider_container').prepend(html).css({
                "marginLeft": -(colwidth * cols) + "px"
              });
            }
        }
      },
      _getBiggestDate: function(array) {
        var date, result, transformed, _i, _len;
        transformed = [];
        for (_i = 0, _len = array.length; _i < _len; _i++) {
          date = array[_i];
          date = date.split('-');
          transformed.push(new Date(Date.UTC(date[0], date[1])).getTime());
        }
        result = Math.max.apply(Math, transformed);
        return new Date(result).getUTCFullYear() + "-" + new Date(result).getUTCMonth();
      },
      _loadNextMonths: function(period) {
        var date;
        switch (this.options.scrollDirection) {
          case "vertical":
            date = this._splitDate(0, [this._getBiggestDate(this._options.loadedMonths)]);
            return this.element.find('.slider_container').append(this._getMonthsByPeriod(date[0], date[1], period, false));
          default:
            date = this._splitDate(0, [this._getBiggestDate(this._options.loadedMonths)]);
            return this.element.find('.slider_container').append(this._getMonthsByPeriod(date[0], date[1], period, false));
        }
      },
      _getPrevMonths: function(period) {
        var animatemargin, cols, colwidth, currentpos, date, html, rowheight, rows;
        if (!this.element.find('.slider_container').is(':animated')) {
          switch (this.options.scrollDirection) {
            case "vertical":
              currentpos = this._parseMargin(this.element.find('.slider_container').css('marginTop'));
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
              currentpos = this._parseMargin(this.element.find('.slider_container').css('marginLeft'));
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
              currentpos = this._parseMargin(this.element.find('.slider_container').css('marginTop'));
              rowheight = this.element.find('.month_box').outerHeight(true);
              rows = period / this.options.monthScrollPeriod;
              animatemargin = currentpos - (rowheight * rows);
              date = this._splitDate(this._options.displayedMonths.length - 1, this._options.displayedMonths);
              return this.element.find('.slider_container').append(this._getMonthsByPeriod(date[0], date[1], period)).animate({
                marginTop: animatemargin + "px"
              }, this.options.animateSpeed);
            default:
              currentpos = this._parseMargin(this.element.find('.slider_container').css('marginLeft'));
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
      _parseMargin: function(elem) {
        if (elem === "auto") {
          elem = 0;
        }
        return parseFloat(elem);
      },
      _startup: function() {
        var _this = this;
        if (this.options.mode === "datePicker") {
          this.inputElem = $(this.element[0]);
          this.inputElem.after(this._getCalendar("<div class=\"bearcal-wrapper " + this.options.appendClass + "\">", "</div>")).next().hide();
          this.element = this.inputElem.next('.bearcal-wrapper');
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
        } else {
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
        if (this.options.track) {
          return this._track();
        }
      },
      _create: function() {
        var _this;
        $.a07.BearCal.instances.push(this.element);
        _this = this;
        this._options = $.extend(true, {}, this._options);
        if (this.options.json.enable) {
          return $.getJSON(this.options.json.url, function(data) {
            if (_this.options.json.type === "range") {
              data = _this._prepareRange(data);
            }
            $.extend(_this._options.loadedData, data);
            return _this._startup();
          });
        } else {
          return _this._startup();
        }
      },
      _UTCify: function(date) {
        var day, hour, min, month, sec, year;
        year = date.slice(0, 4);
        month = date.slice(5, 7);
        month--;
        day = date.slice(8, 10);
        hour = date.slice(11, 13);
        min = date.slice(14, 16);
        sec = date.slice(17, 19);
        return Date.UTC(year, month, day, hour, min, sec);
      },
      _prepareRange: function(data) {
        var date, day, endDate, startDate, tmp, _i, _len, _ref;
        tmp = {
          availability: []
        };
        _ref = data.availability;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          day = _ref[_i];
          if (day.place === "start" || day.place === "start-end") {
            tmp.availability.push({
              date: day.date,
              delimiter: day.delimiter,
              place: day.place,
              type: day.type
            });
          } else if (day.place === "end") {
            startDate = new Date(this._UTCify(tmp.availability[tmp.availability.length - 1].date));
            endDate = new Date(this._UTCify(day.date));
            while (endDate.getTime() > startDate.getTime()) {
              startDate = new Date(startDate.getTime() + 43200000);
              date = this._prepareDate(startDate);
              tmp.availability.push({
                date: date,
                delimiter: "false",
                place: "in-between",
                type: day.type
              });
            }
            tmp.availability[tmp.availability.length - 1].delimiter = day.delimiter;
            tmp.availability[tmp.availability.length - 1].place = day.place;
          }
        }
        return tmp;
      },
      _prepareDate: function(date) {
        var pad;
        pad = function(n) {
          if (n < 10) {
            return "0" + n;
          } else {
            return n;
          }
        };
        return date.getUTCFullYear() + "-" + pad(date.getUTCMonth() + 1) + "-" + pad(date.getUTCDate()) + "T" + pad(date.getUTCHours()) + ":" + pad(date.getUTCMinutes()) + ":" + pad(date.getUTCSeconds());
      },
      _getNextDateDOMObj: function(date) {
        var newDate, time;
        time = new Date(this._UTCify(date)).getTime();
        newDate = this._prepareDate(new Date(time + 43200000));
        return $('.' + this.options.trackClass + ' div[data-date="' + newDate + '"]');
      },
      _getPrevDateDOMObj: function(date) {
        var newDate, time;
        time = new Date(this._UTCify(date)).getTime();
        newDate = this._prepareDate(new Date(time - 43200000));
        return $('.' + this.options.trackClass + ' div[data-date="' + newDate + '"]');
      },
      _init: function() {
        return this._setDate();
      },
      destroy: function() {},
      _setOption: function(key, value) {}
    });
    $.extend($.a07.BearCal, {
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
    return $.fn.reverse = [].reverse;
  })(jQuery, window, document);

}).call(this);
