(($, window, document) ->
  $.widget "a07.BearCal",
    options             :
      startDate         : new Date()
      mode              : "interactive"
      period            : 12
      monthScrollPeriod : 4
      yearScrollPeriod  : 12
      monthFullName     : ['January','February','March','April','May','June','July','August','September','October','November','December']
      days              : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
      nthMonth          : 4
      nthMonthClass     : "endrow"
      appendClass       : ""
      scrollDirection   : "vertical"
      animateSpeed      : 500
      nextPeriodHtml    : -> "<a href=\"#\" class=\"next_months\">Next #{@monthScrollPeriod} months</a><a href=\"#\" class=\"next_year\">Next #{@yearScrollPeriod} months</a>"
      prevPeriodHtml    : -> "<a href=\"#\" class=\"prev_year\">Previous #{@yearScrollPeriod} months</a><a href=\"#\" class=\"prev_months\">Previous #{@monthScrollPeriod} months</a>"
      highlightable     : true
      boxClass          : 
        am              : "am_box"
        pm              : "pm_box"
        fullDay         : "day_box"
      trackClass        : "track"
      defaultStatusType : "available"
      reverseTypes      :
        available       : "unavailable"
        unavailable     : "available"
      hoverStates       : 
        am              :
          available     : "hover_available_am"
          unavailable   : "hover_unavailable_am"
        pm              :
          available     : "hover_available_pm"
          unavailable   : "hover_unavailable_pm"
      highlightStates   :
        am              :
          available     : "highlight_available_am"
          unavailable   : "highlight_unavailable_am"
        pm              :
          available     : "highlight_available_pm"
          unavailable   : "highlight_unavailable_pm"
      setStates         : 
        am              :
          available     : ""
          unavailable   : "unavailable am"
          booked        : "booked am"
          delimiter     : "delimiter_am"
        pm              :
          available     : ""
          unavailable   : "unavailable pm"
          booked        : "booked pm"
          delimiter     : "delimiter_pm"
      json              : false
      jsonUrl           : ""
      dontTrackStates   : ["booked"]

    _options            :
      loadedData        : {}
      loadedMonths      : [] 
      displayedMonths   : []
      startDate         : null
      endDate           : null
      state             : null
    
    # Get current calendar state in JSON format
    getJSON : () ->
      _this = @

      json = { "availability" : [] }
      @element.find('.'+@options.boxClass.fullDay).each () ->
        elem = $(@)
        json.availability.push
          "date"        : elem.find('.'+_this.options.boxClass.am).attr('data-date')
          "type"        : elem.find('.'+_this.options.boxClass.am).attr('data-status-type')
          "delimiter"   : elem.find('.'+_this.options.boxClass.am).attr('data-delimiter')
        json.availability.push
          "date"        : elem.find('.'+_this.options.boxClass.pm).attr('data-date')
          "type"        : elem.find('.'+_this.options.boxClass.pm).attr('data-status-type')
          "delimiter"   : elem.find('.'+_this.options.boxClass.pm).attr('data-delimiter')
      JSON.stringify(json, null, '\t')

    # Date comparisons
    _compareDates : (s_date, e_date, operator) ->
      s_date = @_parseDate(s_date)
      e_date = @_parseDate(e_date)

      switch operator
        when "<" then new Date(s_date).getTime() < new Date(e_date).getTime()
        when ">" then new Date(s_date).getTime() > new Date(e_date).getTime()
        when ">=" then new Date(s_date).getTime() >= new Date(e_date).getTime()
        when "<=" then new Date(s_date).getTime() <= new Date(e_date).getTime()
        when "==" then new Date(s_date).getTime() is new Date(e_date).getTime()

    # Convert from current format ISO 8601 to RFC2822 because IE8 doesn't support ES5
    _parseDate : (d) ->
      months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
      year   = d.slice(0,4)
      month  = months[d.slice(5,7)-1]
      day    = d.slice(8,10)
      time   = d.slice(-8, d.length)
      "#{month} #{day}, #{year} #{time}"

    # States not to track
    _trackable: (timeOfDay) ->
      $.inArray(timeOfDay.attr('data-status-type'), @options.dontTrackStates) is -1

    # Tracks the events relating to calendar interactivity
    _track: () ->
      _this = @
      @element.on
        mousemove: (event) ->
          parent = $(@).find('div')
          amChild = $(@).find('.'+_this.options.boxClass.am)
          pmChild = $(@).find('.'+_this.options.boxClass.pm)

          if _this._getLocation(@, event) # We're in the upper left corner (AM)

            if !_this._highlightable() #If not highlightable, that means we just have to highlight our current cursor position and not a date span
              parent.removeClass(_this._getAllClasses(_this.options.hoverStates)) # Remove all previous hover states classes
              hoverState = _this._getReverseType(amChild) # Figure out which hover state to apply
              amChild.addClass(_this.options.hoverStates.am[hoverState]) # Add hover state class to am div

            else # It's highlightable, that means we're currently selecting a date span
              _this._eraseHighlights() # Remove all highlight classes
              _this._trackHighlights @, "T00:00:00" # Start highlight tracking
              
          else # We're in the lower right corner (PM)
            
            if !_this._highlightable() #If not highlightable, that means we just have to highlight our current cursor position and not a date span
              parent.removeClass(_this._getAllClasses(_this.options.hoverStates)) # Remove all previous hover states classes
              hoverState = _this._getReverseType(pmChild) # Figure out which hover state to apply
              pmChild.addClass(_this.options.hoverStates.pm[hoverState]) # Add hover state class to pm div
              
            else # It's highlightable, that means we're currently selecting a date span
              _this._eraseHighlights() # Remove all highlight classes
              _this._trackHighlights @, "T12:00:00" # Start highlight tracking

        mouseleave: (event) ->
          parent = $(@).find('div')
          parent.removeClass(_this._getAllClasses(_this.options.hoverStates)) # The mouse has left the box, so we remove all remaining hover classes for this box.

        click: (event) ->
          amChild = $(@).find('.'+_this.options.boxClass.am)
          pmChild = $(@).find('.'+_this.options.boxClass.pm)

          if _this._getLocation(@, event) # We're in the upper left corner (AM)
            if _this._trackable(amChild) # Check to see if it's trackable (Could be a state that we don't want to track)
              _this._setDates(this, "T00:00:00") # Set the date as AM
          else # We're in the lower right corner (PM)
            if _this._trackable(pmChild) # Check to see if it's trackable (Could be a state that we don't want to track)
              _this._setDates(this, "T12:00:00") # Set the date as PM

        "."+@options.trackClass # Why not just track the each daybox instead of having an extra "track" class? Because we might not want to track previous dates to the current date for example.

    # Returns event location within a square split diagonally from top-right to bottom-left
    # Params:
    #   that:   this of calling function
    #   event:  mouse event 
    _getLocation: (that, event) ->
      offset = $(that).offset()
      h = $(that).height() + offset.top
      # True means it's upper left, false means lower right
      (h - event.pageY) > (event.pageX - offset.left)

    # Returns bool whether the days can be highlighted
    # Simply checks that there's a startDate and no endDate
    _highlightable: ->
      @_options.startDate and !@_options.endDate

    # Remove all highlight classes
    _eraseHighlights: ->
      $("."+@options.boxClass.am+", ."+@options.boxClass.pm).removeClass(@_getAllClasses(@options.highlightStates))

    # Get reverse status type
    _getReverseType: (that) ->
      @options.reverseTypes[$(that).attr('data-status-type')]

    # Applied highlight classes defined in @options.highlightStates for AM PM or full day_box
    # while mouse is moving across the calendar
    # 
    # There are 2 logic groups - each group requires different logic
    # Group 1: If the cursor is on the left side(<) of the start date
    # Group 2: If the cursor is on the right side(>) of the start date
    # Group 3: If the cursor is on the start date
    #
    # Params:
    #   that: the parent event we're reacting to
    #   pos:  whether the cursor is in am or pm, valid values["T00:00:00", "T12:00:00"]
    #   highlightState: which state to apply
    _trackHighlights: (that, pos, highlightState) ->
      _this = @
      cursorPos = $(that).attr("data-date") + pos #True cursor position

      @element.find("."+@options.boxClass.fullDay).each -> #Loop through all day_box(es)
        
        #Logic group 1
        if cursorPos < _this._options.startDate
          cursorAdj = $(that).attr("data-date") + "T00:00:00" #Adjusted cursor position required for logic testing
          each_box = $(@).attr("data-date") + "T00:00:00"
          
          #Is the current each_box between the @_options.startDate and cursor
          if _this._compareDates(each_box, cursorAdj, ">=") and _this._compareDates(each_box, _this._options.startDate, "<=")
            amChild = $(@).find('.'+_this.options.boxClass.am)
            pmChild = $(@).find('.'+_this.options.boxClass.pm)

            #If cursorAdj == each_box we need to look closer to see if we need to apply halfday highlighting
            if _this._compareDates(each_box, cursorAdj, "==") and ~cursorPos.indexOf("T12:00:00")
              if _this._trackable(pmChild) # Only add class if it's trackable
                pmChild.addClass _this.options.highlightStates.pm[_this._options.state]

            #If  each_box is equal to the startdate then we just apply a halday highlight
            else if _this._compareDates(each_box, _this._options.startDate, "==")
              if _this._trackable(amChild) # Only add class if it's trackable
                amChild.addClass _this.options.highlightStates.am[_this._options.state] 
            else
              # Add both am and pm highlight class to am and pm div respectively
              if _this._trackable(amChild) # Only add class if it's trackable
                amChild.addClass _this.options.highlightStates.am[_this._options.state] 
              if _this._trackable(pmChild) # Only add class if it's trackable
                pmChild.addClass _this.options.highlightStates.pm[_this._options.state] 
        
        #Logic group 2
        else if cursorPos > _this._options.startDate
          cursorAdj = $(that).attr("data-date") + "T12:00:00" #Adjusted cursor position required for logic testing
          each_box = $(@).attr("data-date") + "T12:00:00"
          
          #Is the current each_box between the @_options.startDate and cursor
          if _this._compareDates(each_box, cursorAdj, "<=") and _this._compareDates(each_box, _this._options.startDate, ">=")
            amChild = $(@).find('.'+_this.options.boxClass.am)
            pmChild = $(@).find('.'+_this.options.boxClass.pm)
            
            #If cursorAdj == each_box we need to look closer to see if we need to apply halfday highlighting
            if _this._compareDates(each_box, cursorAdj, "==") and ~cursorPos.indexOf("T00:00:00")
              if _this._trackable(amChild) # Only add class if it's trackable
                $(@).find("."+_this.options.boxClass.am).addClass _this.options.highlightStates.am[_this._options.state]
              
            #If  each_box is equal to the startdate then we just apply a halfday highlight
            else if _this._compareDates(each_box, _this._options.startDate, "==")
              if _this._trackable(pmChild) # Only add class if it's trackable
                $(@).find("."+_this.options.boxClass.pm).addClass _this.options.highlightStates.pm[_this._options.state]
            else
              # Add both am and pm highlight class to am and pm div respectively
              if _this._trackable(amChild) # Only add class if it's trackable
                $(@).find("."+_this.options.boxClass.am).addClass _this.options.highlightStates.am[_this._options.state] 
              if _this._trackable(pmChild) # Only add class if it's trackable
                $(@).find("."+_this.options.boxClass.pm).addClass _this.options.highlightStates.pm[_this._options.state] 

        # Logic group 3
        else if cursorPos is _this._options.startDate
          amChild = $(@).find('.'+_this.options.boxClass.am)
          pmChild = $(@).find('.'+_this.options.boxClass.pm)
          
          each_box = $(@).attr("data-date") + "T00:00:00"
          if _this._compareDates(each_box, cursorPos, "==")
            if _this._trackable(amChild) # Only add class if it's trackable
              $(@).find("."+_this.options.boxClass.am).addClass _this.options.highlightStates.am[_this._options.state] 

          each_box = $(@).attr("data-date") + "T12:00:00"
          if _this._compareDates(each_box, cursorPos, "==")
            if _this._trackable(pmChild) # Only add class if it's trackable
              $(@).find("."+_this.options.boxClass.pm).addClass _this.options.highlightStates.pm[_this._options.state] 


    # Logic behind whether states should be applied to date selection
    #
    # There are 3 logic groups - each group requires slight logic variations
    # Group 1: If the start date is earlier then the end date
    # Group 2: If the end date is earlier then the start date
    # Group 3: If the start date and end date are the same
    #
    # Params:
    #   that: this from calling function
    #   pos:  whether the cursor is in am or pm, valid values["T00:00:00", "T12:00:00"]
    _setDates : (that, pos) ->
      _this = @ 

      switch @options.mode
        when "datePicker"
          data =    
            elem       : that
            date       : $(that).attr("data-date") + pos
            parentElem : @element
            inputElem  : @inputElem
          
          @_trigger("datePicked", 0, data)
        else
          # If both start and end dates are set, we reset them
          if @_options.startDate and @_options.endDate
            @_options.startDate = @_options.endDate = @_options.state = null # Reset start, end dates and state
          
          #Is the start date set? YES
          if @_options.startDate
            @_options.endDate = $(that).attr("data-date") + pos #Set end date
            
            # Trigger set end date event
            @_trigger("endDateSet", 0, @_options.endDate)
            
            #Logic group 1
            if @_compareDates(@_options.startDate, @_options.endDate, "<")
              @element.find("."+@options.boxClass.fullDay).each -> #Apply status classes to in-between dates
                amChild = $(@).find('.'+_this.options.boxClass.am)
                pmChild = $(@).find('.'+_this.options.boxClass.pm)

                if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T12:00:00", "<") and _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T00:00:00", ">") 

                  if _this._trackable(amChild) # Only add class if it's trackable
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.am[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)

                  if _this._trackable(pmChild) # Only add class if it's trackable
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.pm[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)

                else if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T12:00:00", "==")
                  if _this._trackable(pmChild) # Only add class if it's trackable
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)
                    .attr('data-delimiter', 'true')

                else if _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T00:00:00", "==")
                  if _this._trackable(amChild) # Only add class if it's trackable
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)
                    .attr('data-delimiter', 'true')

              @_eraseHighlights()
              true #Return true to let know that an end date was set
            
            #Logic group 2
            else if @_compareDates(@_options.startDate, @_options.endDate, ">")
              @element.find("."+@options.boxClass.fullDay).each -> #Apply status classes to in-between dates
                amChild = $(@).find('.'+_this.options.boxClass.am)
                pmChild = $(@).find('.'+_this.options.boxClass.pm)

                if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T00:00:00", ">") and _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T12:00:00", "<")
                  if _this._trackable(amChild) # Only add class if it's trackable
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.am[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)

                  if _this._trackable(pmChild) # Only add class if it's trackable
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.pm[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)

                else if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T00:00:00", "==")
                  if _this._trackable(amChild) # Only add class if it's trackable
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)
                    .attr('data-delimiter', 'true')

                else if _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T12:00:00", "==")
                  if _this._trackable(pmChild) # Only add class if it's trackable
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)
                    .attr('data-delimiter', 'true')

              @_eraseHighlights()
              true #Return true to let know that an end date was set
            
            #Logic group 3
            else
              @element.find("."+@options.boxClass.fullDay).each -> #Apply status classes to in-between dates
                amChild = $(@).find('.'+_this.options.boxClass.am)
                pmChild = $(@).find('.'+_this.options.boxClass.pm)

                if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T00:00:00", "==")
                  if _this._trackable(amChild) # Only add class if it's trackable
                    amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)
                    .attr('data-delimiter', 'true')

                else if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T12:00:00", "==")
                  if _this._trackable(pmChild) # Only add class if it's trackable
                    pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                    .addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]) 
                    .attr('data-status-type', _this._options.state)
                    .attr('data-delimiter', 'true')
            
              true #Return true to let know that an end date was set
      
          # Start date not set
          else
            @_options.startDate = $(that).attr("data-date") + pos #Set start date
            @_options.state = if pos is "T00:00:00" # Set the state to use
              _this._getReverseType($(that).find('.'+_this.options.boxClass.am))
            else
              _this._getReverseType($(that).find('.'+_this.options.boxClass.pm))

            # Trigger set start date event
            @_trigger("startDateSet", 0, @_options.startDate)

            false #Return false to let know that no end date was set

    # Recursively return all values within an object literal
    _getAllClasses: (obj) ->
      _this = @
      results = ""
      $.each obj, (index, value) ->
        if obj[index] instanceof Object
          results += _this._getAllClasses(obj[index])
        else
          results += value + " "
      results

    # Turn date string into Date object
    _toDate: (date) ->
      new Date(date)

    # Set startdate as a Date object
    _setDate: ->
      if typeof @options.startDate isnt "object"
        date = @options.startDate.split('/')
        @options.startDate = new Date(date[0], date[1], date[2])
   
    # Get the day of the week from [0..6] starting on Sunday
    _getDayOfWeek: (year, month, day) ->
      new Date(year, month, day).getDay()

    # Get amount of days in a month (http://bit.ly/PaZvjH)
    _getDaysInMonth: (year, month)  ->
      new Date(year, month+1, 0).getDate() 

    # Generate weekday titles html
    _getWeekdaysHtml: ->
      weekdayshtml = ""
      for day in @options.days
        weekdayshtml += "<div class=\"wday_box\">#{day.charAt(0)}</div>\n"
      weekdayshtml

    _getDaysHtml: (year, month) ->
      dayshtml = ""
      daycount = 0
      
      # Find out what position to start first day on and append blanks if needed
      blanks = @_getDayOfWeek(year, month, 1)
      if blanks > 0
        i = 0
        while i < blanks
          dayshtml += "<div class=\"empty_day_box\"></div>"
          daycount++
          i++

      # Start adding days
      states = {}
      i = 0
      while i < @_getDaysInMonth(year,month)
        # Reset
        states = {
          am          : 
            type      : @options.defaultStatusType
            delimiter : "false"
          pm          : 
            type      : @options.defaultStatusType
            delimiter : "false"
        }

        # Perform some date formating modifications so that it plays nice with the Date object
        fulldate = "#{year}-#{@_pad(parseInt(month)+1,2)}-#{@_pad(i+1,2)}"

        # If JSON enabled, check to see if we have to apply any extra classes to the day
        if @_options.loadedData.availability?
          for status in @_options.loadedData.availability
            if status.date is fulldate+"T00:00:00"
              states.am.type       = status.type
              states.am.delimiter  = status.delimiter
            else if status.date is fulldate+"T12:00:00"
              states.pm.type       = status.type
              states.pm.delimiter  = status.delimiter


        # Create day DOM element
        dayshtml += """
                    <div class="#{@options.boxClass.fullDay} #{@options.trackClass}" data-date="#{fulldate}">
                      <div class="#{@options.boxClass.am} #{@options.setStates.am[states.am.type]} #{if states.am.delimiter is "true" then @options.setStates.am.delimiter else ""}" data-date="#{fulldate}T00:00:00" data-status-type="#{states.am.type}" data-delimiter="#{states.am.delimiter}">
                        <div class="#{@options.boxClass.pm} #{@options.setStates.pm[states.pm.type]} #{if states.pm.delimiter is "true" then @options.setStates.pm.delimiter else ""}" data-date="#{fulldate}T12:00:00" data-status-type="#{states.pm.type}" data-delimiter="#{states.pm.delimiter}">
                          #{i+1}
                        </div>
                      </div>
                    </div>
                    """

        # Count 'em for good measure
        daycount++
        i++

      # Ensure there are 42 day boxes that way each month contains the same amount of boxes (Formatting goodness) 
      while daycount < 42
        dayshtml += "<div class=\"empty_day_box\"></div>"
        daycount++

      dayshtml

    # Find best place to popup the date picker
    # Will always place below first, if top and below are both lacking in space, below will be used
    # Params:
    #   base : the jquery DOM object to to place the elem by
    #   elem : the jquery DOM object(calendar) to position
    _placePopup: (base, elem) ->
      currView = new Array()
      currView['top'] = $(window).scrollTop() # Upper limit area of the viewport that's currently in view
      currView['bot'] = $(window).height() + currView['top'] # Bottom limit area of the viewport that's currently in view
      elemHeight = elem.outerHeight(true) # Element height
      baseTopOffset = base.offset().top - base.offsetParent().offset().top # Find nearest parent with an offset that'll influence absolute positioning and substract it
      baseLeftOffset = base.offset().left - base.offsetParent().offset().left
      botPlace = baseTopOffset + base.outerHeight(true) # Where to place the element if placing below the base
      topPlace = baseTopOffset - elemHeight # Where to place the element if placing above the base
      botCalPos = botPlace + elemHeight # Coordinates required to place the element below the base
      topCalPos = baseTopOffset - elemHeight # Coordinates require to place the element above the base

      if (botCalPos <= currView['bot']) or (topCalPos < currView['top']) # Is there space to place the elememt below the base?
        elem.css
          top: botPlace + "px"
          left: baseLeftOffset + "px" 
      else
        elem.css
          top: topPlace + "px"
          left: baseLeftOffset + "px" 

    # Helper function to pad dates
    _pad: (num, places) ->
      zero = places - num.toString().length + 1
      Array(+(zero > 0 and zero)).join("0") + num

    _getMonth: (year, month) ->

      # Track loaded months
      @_setLoadedMonths(year, month)

      # Track displayed months only if there are less months then the display period (This should only happen on initial load of calendar)
      @_setDisplayedMonths(year, month) if @_options.displayedMonths.length < @options.period

      # Check to see if we have to add a class for the nth month
      nth = @_options.loadedMonths.length % @options.nthMonth
      
      # Prepare month
      """
      <div class="month_box #{if nth is 0 then @options.nthMonthClass else ""}">
        <div class="month_header">#{@options.monthFullName[month]} #{year}</div>
        #{@_getWeekdaysHtml()}
        #{@_getDaysHtml(year, month)}
      </div>
      """

    _setLoadedMonths: (year, month) ->
      @_options.loadedMonths.push(year + "-" + month)

    _setDisplayedMonths: (year, month, direction) ->
      # We want to store the displayed months so we can then call it on click to then tell if we need to load more months or just animate margin.
      # We need to _setDisplayedMonths in _getMonth and _getMonthsByPeriod
      @_options.displayedMonths.push(year + "-" + month)
      @_options.displayedMonths.sort(@_dateCompare)

      if typeof direction isnt "undefined"
        @_options.displayedMonths.pop() if direction is -1
        @_options.displayedMonths.shift() if direction is 1
        
    # Extends the functionality of the Array.sort() function to sort by Date.getTime()
    _dateCompare : (a, b) ->
      a = a.split("-")
      b = b.split("-")
      (new Date(a[0], a[1]).getTime()) - (new Date(b[0], b[1]).getTime())
      
    _getCalendar: (wrapperStart, wrapperEnd) ->
      # Trigger prebuild
      @_trigger("beforebuild")

      calendarhtml = ""

      #Start of optional wrapper
      calendarhtml += wrapperStart if typeof wrapperStart isnt "undefined"

      calendarhtml += @options.prevPeriodHtml()
      calendarhtml += @options.nextPeriodHtml() if @options.scrollDirection is "horizontal"
      calendarhtml += "<div class=\"period_box clearfix\">\n  <div class=\"slider_container clearfix\">"
      year = @options.startDate.getFullYear()
      month = @options.startDate.getMonth()

      i = 0
      while i < @options.period
        # Track year change and react accordingly
        if month > 11 
          month = 0  
          year++

        calendarhtml += @_getMonth(year, month)
        month++
        i++

      calendarhtml += "</div></div>"
      calendarhtml += @options.nextPeriodHtml() if @options.scrollDirection is "vertical"

      # End of optional wrapper
      calendarhtml += wrapperEnd if typeof wrapperEnd isnt "undefined" 

      calendarhtml

    _getMonthsByPeriod: (year, month, period) -> 
      movement = if period < 0 then -1 else 1
      i = Math.abs(period)
      results = []
      html = ""
    
      while i isnt 0
        month += movement
        tmp = month % 12
        _month = if tmp < 0 then (tmp+12) else tmp
        if movement is -1
          year = if _month is 11 then year + movement else year
        else
          year = if _month is 0 then year + movement else year
        results.push(year + "-" + _month)
        --i

      if movement is -1 then results.reverse()
      
      for result in results
        date = result.split("-")
        html += @_getMonth(date[0], date[1]) if ~$.inArray(result, @_options.loadedMonths) is 0
        @_setDisplayedMonths(date[0], date[1], movement)

      html

    _splitDate: (index, source) ->
      date = source[index].split("-")
      i = 0
      while i < date.length
        date[i] = parseInt(date[i])
        i++
      date

    # Gets previous months and adjusts the view accordingly
    _getPrevMonths: (period) ->
      if !@element.find('.slider_container').is(':animated')
        switch @options.scrollDirection
          when "vertical"
            currentpos = @_parseMargin(@element.find('.slider_container').css('marginTop'))
            rowheight = @element.find('.month_box').outerHeight(true)
            rows = (period / @options.monthScrollPeriod)
            animatemargin = currentpos + (rowheight * rows) 

            animatemargin = if animatemargin is (rowheight * rows) or animatemargin > 0 then 0 else animatemargin
            
            date = @_splitDate(0, @_options.displayedMonths)
            html = @_getMonthsByPeriod(date[0],date[1],-period)
            if html.length > 0
              @element.find('.slider_container')
                      .prepend(html)
                      .css("marginTop" : -(rowheight * rows)+"px")
                      .animate({marginTop: animatemargin+"px"}, @options.animateSpeed)
            else @element.find('.slider_container').animate({marginTop: animatemargin+"px"}, @options.animateSpeed)
          else
            currentpos = @_parseMargin(@element.find('.slider_container').css('marginLeft'))
            colwidth = @element.find('.month_box').outerWidth(true)
            cols = (period / @options.monthScrollPeriod)
            animatemargin = currentpos + (colwidth * cols) 

            animatemargin = if animatemargin is (colwidth * cols) or animatemargin > 0 then 0 else animatemargin
            
            date = @_splitDate(0, @_options.displayedMonths)
            html = @_getMonthsByPeriod(date[0],date[1],-period)
            if html.length > 0
              @element.find('.slider_container')
                      .prepend(html)
                      .css("marginLeft" : -(colwidth * cols)+"px")
                      .animate({marginLeft: animatemargin+"px"}, @options.animateSpeed)
            else @element.find('.slider_container').animate({marginLeft: animatemargin+"px"}, @options.animateSpeed)


    # Gets next months and adjusts the view accordingly
    _getNextMonths: (period) ->
      if !@element.find('.slider_container').is(':animated')
        switch @options.scrollDirection
          when "vertical"
            currentpos = @_parseMargin(@element.find('.slider_container').css('marginTop'))
            rowheight = @element.find('.month_box').outerHeight(true)
            rows = (period / @options.monthScrollPeriod)
            animatemargin = currentpos - (rowheight * rows) 

            date = @_splitDate(@_options.displayedMonths.length-1, @_options.displayedMonths)
            @element.find('.slider_container')
                    .append(@_getMonthsByPeriod(date[0],date[1],period))
                    .animate({marginTop: animatemargin+"px"}, @options.animateSpeed)
          else
            currentpos = @_parseMargin(@element.find('.slider_container').css('marginLeft'))
            colwidth = @element.find('.month_box').outerWidth(true)
            cols = (period / @options.monthScrollPeriod)
            animatemargin = currentpos - (colwidth * cols) 

            date = @_splitDate(@_options.displayedMonths.length-1, @_options.displayedMonths)
            @element.find('.slider_container')
                    .append(@_getMonthsByPeriod(date[0],date[1],period))
                    .animate({marginLeft: animatemargin+"px"}, @options.animateSpeed)

    # Dealing with IE7/8 ridiculousness!!
    _parseMargin: (elem) ->
      elem = 0 if elem is "auto"
      parseFloat(elem)

    _startup: ->
      # Check to see if it's an input and act accordingly
      switch @options.mode
        when "datePicker"
          # Place input element into it's own var
          @inputElem = $(@element[0])

          # Add the calendar and hide it
          @inputElem.after(@_getCalendar("<div class=\"bearcal-wrapper #{@options.appendClass}\">","</div>")).next().hide()

          # Overwrite the element with the calendar
          @element = @inputElem.next('.bearcal-wrapper')

          # Watch for focus
          @inputElem.on "focus", =>
            $('.bearcal-wrapper').fadeOut('fast')
            @_placePopup(@inputElem, @element)
            @element.fadeIn('fast')

          # Watch for clicks outside the calendar if it's toggled and close it
          $(document).off("click.a07").on "click.a07", (event) =>
            if $('.bearcal-wrapper').is(':visible')
              if ($(event.target).attr('class') isnt 'bearcal-wrapper') and # The click isn't on the calendar
                 ($(event.target).parents('.bearcal-wrapper').length is 0) and # The click isn't on any element where the calendar is its parent
                 ($.inArray($(event.target).get(0), $.a07.BearCal.getDOMInstances()) < 0) # This click isn't on any DOM element that triggers the calendar (i.e an input field)
                   $('.bearcal-wrapper').fadeOut('fast')
              
        else
          @element.append @_getCalendar()

      @element.find('.prev_months').click =>
        @_getPrevMonths(@options.monthScrollPeriod)
        return false

      @element.find('.next_months').click =>
        @_getNextMonths(@options.monthScrollPeriod)
        return false

      @element.find('.prev_year').click =>
        @_getPrevMonths(@options.yearScrollPeriod)
        return false

      @element.find('.next_year').click =>
        @_getNextMonths(@options.yearScrollPeriod)
        return false

      @_track()
      
    _create: ->
      # Store widget instance in array
      $.a07.BearCal.instances.push(@element)

      _this = @

      # Create per instance copy of "private" object
      @_options = $.extend(true, {}, @_options)

      # Check to see if we should load some JSON data
      if @options.json 
        $.getJSON @options.jsonUrl, (data) ->
          $.extend(_this._options.loadedData, data)
          _this._startup() #This needs to be here, in the successful callback or else it could keep running without loading all the data
      else
        _this._startup()


    _init: ->
      # We call set date to ensure a Date object is passed as the options.startDate value
      @_setDate()

    destroy: ->

    _setOption: (key, value) ->

  $.extend $.a07.BearCal,
    instances       : []
    getDOMInstances : ->
      t = []
      $.each @instances, (i,v) ->
        t.push(v.get(0))
      t

) jQuery, window, document
