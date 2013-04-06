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
      boxClass          : 
        am              : "am_box"
        pm              : "pm_box"
        fullDay         : "day_box"
      track             : true
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
      json              :
        enable          : false
        type            : "all" # all or range
        url             : ""
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
        amElem = $(@).find('.'+_this.options.boxClass.am)
        pmElem = $(@).find('.'+_this.options.boxClass.pm)

        json.availability.push
          "date"        : amElem.attr('data-date')
          "type"        : amElem.attr('data-status-type')
          "delimiter"   : amElem.attr('data-delimiter')
          "place"       : amElem.attr('data-range-place')

        json.availability.push
          "date"        : pmElem.attr('data-date')
          "type"        : pmElem.attr('data-status-type')
          "delimiter"   : pmElem.attr('data-delimiter')
          "place"       : pmElem.attr('data-range-place')

      JSON.stringify(json, null, '\t')

    # Set dates on an already loaded calendar
    # dates takes an the availability object which contains an array of halfdays
    # range indicates whether halfday objects are provide in a range format
    setLiveDates : (dates, range = false) ->
      _this = @

      # Prepare dates if it's in range format
      if range is true
        dates = @_prepareRange(dates)

      $.each dates.availability, (index, value) ->

        # Add the halfday to the loadedData object array
        _this._options.loadedData.availability.push(value)

        # Check to see if that specific halfday is already loaded to the DOM
        matchedElement = _this.element.find("." + _this.options.boxClass.fullDay + " div[data-date='" + value.date + "']")

        # If the array isn't empty, we have a successful match
        if matchedElement.length is 1
          # Store the time of day (am or pm)
          tod = if value.date.slice(10,19) is "T00:00:00" then "am" else "pm"

          # Update data attributes
          matchedElement.attr
            dataStatusType: value.type
            dataDelimiter: value.delimiter
            dataPlace: value.place

          # Update classes
          matchedElement.addClass(_this.options.setStates[tod][value.type] + " " + if value.delimiter is "true" then _this.options.setStates[tod].delimiter else "")


    # Get last occurence index of value in an array
    _getLastIndex : (arr, needle) ->
      idx = $.inArray(needle, arr)
      indices = []

      while ( idx isnt -1 ) 
        indices.push(idx)
        idx = $.inArray(needle, arr, idx+1)
      
      indices[indices.length-1]

    # Get current calendar in JSON format filtered by states(array) and optional range grouping
    getJSONByStates : (states, range = false) ->
      _this = @

      # Define variables
      nextStatusType = []
      nextArrayIndex = []

      json = { "availability" : [] }

      # Make sure we have complete ranges
      while @element.find('.'+@options.boxClass.fullDay+' .'+@options.boxClass.am).eq(0).attr('data-range-place') is 'in-between'
        @_loadPrevMonths(@options.monthScrollPeriod)

      while @element.find('.'+@options.boxClass.fullDay+' .'+@options.boxClass.pm).reverse().eq(0).attr('data-range-place') is 'in-between'
        @_loadNextMonths(@options.monthScrollPeriod)

      @element.find('.'+@options.boxClass.fullDay).each () ->
        amElem = $(@).find('.'+_this.options.boxClass.am)
        pmElem = $(@).find('.'+_this.options.boxClass.pm)

        if $.inArray(amElem.attr('data-status-type'), states) isnt -1
          if (range and $.inArray(amElem.attr('data-range-place'), ['start','end','start-end']) isnt -1) or (!range)
            # If it's the end of a range and it matches a stored status type, we need to place it somewhere specific in the array
            workingIndex = $.inArray(amElem.attr('data-status-type'), nextStatusType) 
            if workingIndex isnt -1 and amElem.attr('data-range-place') is 'end'
              # Get last index of this type of booking
              lastIndex = _this._getLastIndex(nextStatusType, amElem.attr('data-status-type'))
              # Get the array position to know where to push the booking info
              pushPosition = nextArrayIndex[lastIndex]
              # Push the booking onto the array space
              json.availability[pushPosition] =
                "date"        : amElem.attr('data-date')
                "type"        : amElem.attr('data-status-type')
                "delimiter"   : amElem.attr('data-delimiter')
                "place"       : amElem.attr('data-range-place')

              # We no longer need to track these from the array 
              nextArrayIndex.splice(lastIndex,1)
              nextStatusType.splice(lastIndex,1)
            else
              json.availability.push
                "date"        : amElem.attr('data-date')
                "type"        : amElem.attr('data-status-type')
                "delimiter"   : amElem.attr('data-delimiter')
                "place"       : amElem.attr('data-range-place')

            # If the range isn't start-end or end we want to keep a space in the next position of the array for the end of the range
            if amElem.attr('data-range-place') isnt 'start-end' and amElem.attr('data-range-place') isnt 'end'
              # Make a space for the end of the range and get the index for it
              nextArrayIndex.push(json.availability.push(null) - 1)

              # Store the status type
              nextStatusType.push(amElem.attr('data-status-type'))
              

        if $.inArray(pmElem.attr('data-status-type'), states) isnt -1
          if (range and $.inArray(pmElem.attr('data-range-place'), ['start','end','start-end']) isnt -1) or (!range)
            workingIndex = $.inArray(pmElem.attr('data-status-type'), nextStatusType) 
            if workingIndex isnt -1 and pmElem.attr('data-range-place') is 'end'
              # Get last index of this type of booking
              lastIndex = _this._getLastIndex(nextStatusType, pmElem.attr('data-status-type'))
              # Get the array position to know where to push the booking info
              pushPosition = nextArrayIndex[lastIndex]
              # Push the booking onto the array space
              json.availability[pushPosition] =
                "date"        : pmElem.attr('data-date')
                "type"        : pmElem.attr('data-status-type')
                "delimiter"   : pmElem.attr('data-delimiter')
                "place"       : pmElem.attr('data-range-place')

              # We no longer need to track these from the array 
              nextArrayIndex.splice(lastIndex,1)
              nextStatusType.splice(lastIndex,1)
            else
              json.availability.push
                "date"        : pmElem.attr('data-date')
                "type"        : pmElem.attr('data-status-type')
                "delimiter"   : pmElem.attr('data-delimiter')
                "place"       : pmElem.attr('data-range-place')

            # If the range isn't start-end or end we want to keep a space in the next position of the array for the end of the range
            if pmElem.attr('data-range-place') isnt 'start-end' and pmElem.attr('data-range-place') isnt 'end'
              # Make a space for the end of the range and get the index for it
              nextArrayIndex.push(json.availability.push(null) - 1)
              # Store the status type
              nextStatusType.push(pmElem.attr('data-status-type'))

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


    _startRangeLogic : (domElement, defaultPlace = 'start') ->
      oToken = false
      # Get the previous halfday DOM Object
      prevDate = @_getPrevDateDOMObj(domElement.attr('data-date'))

      # Scenario: The start date DOM object currently has no data-range-place applied to it
      if domElement.attr('data-range-place') is ''

        domElement.attr('data-range-place', defaultPlace)
        # These are overwrite tokens, so we don't overwrite the data-range-place on the day we just set
        # when we go through the logic on whether to apply 'in-betewen' states below
        oToken = true 

      if @_options.state is domElement.attr('data-status-type') 
        domElement.attr('data-range-place', 'in-between')
      else
        # Scenario: The start date DOM object currently has a data-range-place applied to it of 'in-between'
        # The start date could only ever be in-between if we're changing a status to the default status (available)
        # For example, clicking within an unavailable range to make some or all of it available
        if domElement.attr('data-range-place') is 'in-between'
          # Sub-scenario: Is the previous halfday DOM object data-range-place value 'in-between'?
          if prevDate.attr('data-range-place') is 'in-between'
            prevDate.attr('data-range-place', 'end')
          # Sub-scenario: Is the previous halfday DOM object data-range-place value 'start'?
          if prevDate.attr('data-range-place') is 'start'
            prevDate.attr('data-range-place', 'start-end')
          if prevDate.attr('data-status-type') is 'booked'
            @_spreadRangeLogic(domElement, 'reverse')

      # Scenario: If the start date needs to be set for the defaultStatusType we don't set data-range-place
      if @_options.state is @options.defaultStatusType
        domElement.attr('data-range-place', '')

      oToken

    _endRangeLogic : (domElement, defaultPlace = 'end') ->
      oToken = false
      nextDate = @_getNextDateDOMObj(domElement.attr('data-date'))

      if domElement.attr('data-range-place') is ''
        domElement.attr('data-range-place', defaultPlace)
        oToken = true
        
      if @_options.state is domElement.attr('data-status-type') 
        domElement.attr('data-range-place', 'in-between')
      else
        if domElement.attr('data-range-place') is 'in-between'
          if nextDate.attr('data-range-place') is 'in-between'
            nextDate.attr('data-range-place', 'start')
          if nextDate.attr('data-range-place') is 'end'
            nextDate.attr('data-range-place', 'start-end')
          if nextDate.attr('data-status-type') is 'booked'
            @_spreadRangeLogic(domElement)

      if @_options.state is @options.defaultStatusType
        domElement.attr('data-range-place', '')

      oToken

    _startEndRangeLogic : (domElement, defaultPlace = 'start-end') ->
      oToken = false
      _this = @

      # Get the next and previous halfday DOM Object
      nextDate = @_getNextDateDOMObj(domElement.attr('data-date'))
      prevDate = @_getPrevDateDOMObj(domElement.attr('data-date'))

      if (domElement.attr('data-range-place') is '')
        domElement.attr('data-range-place', defaultPlace)
        oToken = true

      else

        if domElement.attr('data-range-place') is 'start'

          # Deal with next DOM object first
          if nextDate.attr('data-range-place') is 'in-between'
            nextDate.attr('data-range-place', 'start')
          if nextDate.attr('data-range-place') is 'end'
            nextDate.attr('data-range-place', 'start-end')
          if nextDate.attr('data-status-type') is 'booked'
            @_spreadRangeLogic(domElement)

        if domElement.attr('data-range-place') is 'in-between'

          # Deal with next DOM object first
          if nextDate.attr('data-range-place') is 'in-between'
            nextDate.attr('data-range-place', 'start')
          if nextDate.attr('data-range-place') is 'end'
            nextDate.attr('data-range-place', 'start-end')
          if nextDate.attr('data-status-type') is 'booked'
            @_spreadRangeLogic(domElement)

          # Deal with prev DOM object next
          if prevDate.attr('data-range-place') is 'in-between'
            prevDate.attr('data-range-place', 'end')
          # Sub-scenario: Is the previous halfday DOM object data-range-place value 'start'?
          if prevDate.attr('data-range-place') is 'start'
            prevDate.attr('data-range-place', 'start-end')
          if prevDate.attr('data-status-type') is 'booked'
            @_spreadRangeLogic(domElement, 'reverse')

        if domElement.attr('data-range-place') is 'end'

          # Deal with prev DOM object only
          if prevDate.attr('data-range-place') is 'in-between'
            prevDate.attr('data-range-place', 'end')
          # Sub-scenario: Is the previous halfday DOM object data-range-place value 'start'?
          if prevDate.attr('data-range-place') is 'start'
            prevDate.attr('data-range-place', 'start-end')
          if prevDate.attr('data-status-type') is 'booked'
            @_spreadRangeLogic(domElement, 'reverse')

        if @_options.state is @options.defaultStatusType
          domElement.attr('data-range-place', '')

      oToken

    # This logic is required for the following situation:
    # Given these preexisting ranges are in the same month
    # booked [ 14.PM - 20.AM ]
    # unavailable [ 1.AM - 31.PM ]
    #
    # You then perform these sequence of events
    # 1. start-click on [1.AM] thereby changing it to available
    # 2. end-click on [14.AM] thereby closing the available range right before the booked range 
    #
    # The above action will remove the 'start' from the 'unavailable' range which is desired
    # but now we have the 'end' of the 'unavailable' range just floating without a 'start'
    #
    # Therefore, given what the data-range-place value is on then end-click, the below logic will
    # find the next halfday of the same status-type and apply a 'start' or 'start-end' data-range-place
    # to it. This will effectively keep create a valid 'unavailable' range again.
    #
    # Note: This logic can go both forward and reverse through the calendar
    _spreadRangeLogic : (domElement, direction = "forward") ->
      _this = @
      domElementDate = domElement.attr('data-date')
      domElementType = domElement.attr('data-status-type')
      found = false

      if direction is 'forward'
        # Seek out the next unavailable and apply
        @element.find("."+@options.boxClass.fullDay).each -> 
          amChild = $(@).find('.'+_this.options.boxClass.am)
          pmChild = $(@).find('.'+_this.options.boxClass.pm)
          # if the date is bigger then domElement and is of the same status-type
          # then that's our target.
          if (_this._compareDates(amChild.attr('data-date'), domElementDate, '>')) and (amChild.attr('data-status-type') is domElementType) and (found isnt true)

            if amChild.attr('data-range-place') is 'in-between'
              amChild.attr('data-range-place', 'start')
            if amChild.attr('data-range-place') is 'end'
              amChild.attr('data-range-place', 'start-end')
            found = true

          if (_this._compareDates(pmChild.attr('data-date'), domElementDate, '>')) and (pmChild.attr('data-status-type') is domElementType) and (found isnt true)
            if pmChild.attr('data-range-place') is 'in-between'
              pmChild.attr('data-range-place', 'start')
            if pmChild.attr('data-range-place') is 'end'
              pmChild.attr('data-range-place', 'start-end')
            found = true
      
      if direction is 'reverse'
        # Seek out the next unavailable and apply
        @element.find("."+@options.boxClass.fullDay).reverse().each -> 
          amChild = $(@).find('.'+_this.options.boxClass.am)
          pmChild = $(@).find('.'+_this.options.boxClass.pm)
          # if the date is smaller then domElement and is of the same status-type
          # then that's our target.
          if (_this._compareDates(pmChild.attr('data-date'), domElementDate, '<')) and (pmChild.attr('data-status-type') is domElementType) and (found isnt true)
            if pmChild.attr('data-range-place') is 'in-between'
              pmChild.attr('data-range-place', 'end')
            if pmChild.attr('data-range-place') is 'start'
              pmChild.attr('data-range-place', 'start-end')
            found = true

          if (_this._compareDates(amChild.attr('data-date'), domElementDate, '<')) and (amChild.attr('data-status-type') is domElementType) and (found isnt true)

            if amChild.attr('data-range-place') is 'in-between'
              amChild.attr('data-range-place', 'end')
            if amChild.attr('data-range-place') is 'start'
              amChild.attr('data-range-place', 'start-end')
            found = true


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

      if @options.mode is "datePicker"
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
          
          # Position of start date (T00:00:00/T12:00:00)
          startPos = _this._options.startDate.slice(10,19)

          #Logic group 1
          if @_compareDates(@_options.startDate, @_options.endDate, "<")

            @element.find("."+@options.boxClass.fullDay).each -> #Apply status classes to in-between dates
              amChild = $(@).find('.'+_this.options.boxClass.am)
              pmChild = $(@).find('.'+_this.options.boxClass.pm)

              # This conditional block is only in charge of registering whether it's the start or end of the date range
              # SET START DATE
              if _this._compareDates(_this._options.startDate, $(@).attr('data-date') + startPos, '==')
                # AM START
                if startPos is "T00:00:00"
                  amOToken = _this._startRangeLogic(amChild)
                
                # PM START
                else
                  pmOToken = _this._startRangeLogic(pmChild)

              # SET END DATE
              if _this._compareDates(_this._options.endDate, $(@).attr('data-date') + pos, '==')
                # AM END
                if pos is "T00:00:00"
                  amOToken = _this._endRangeLogic(amChild)

                # PM END
                else
                  pmOToken = _this._endRangeLogic(pmChild)

              # This conditional block assigns the rest of the stuff such as states, delimiters and classes
              if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T12:00:00", "<") and _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T00:00:00", ">") 

                if _this._trackable(amChild) # Only add class if it's trackable
                  amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.am[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : "false"
                  
                  if _this._options.state is _this.options.defaultStatusType
                    amChild.attr('data-range-place', '')
                  else
                    amChild.attr('data-range-place', 'in-between') unless amOToken
                      

                if _this._trackable(pmChild) # Only add class if it's trackable
                  pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.pm[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : "false"
                  
                  if _this._options.state is _this.options.defaultStatusType
                    pmChild.attr('data-range-place', '')
                  else
                    pmChild.attr('data-range-place', 'in-between') unless pmOToken
                      

              else if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T12:00:00", "==")
                if _this._trackable(pmChild) # Only add class if it's trackable
                  pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'true'

              else if _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T00:00:00", "==")
                if _this._trackable(amChild) # Only add class if it's trackable
                  amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]) 
                  .attr
                    'data-status-type'  :  _this._options.state
                    'data-delimiter'    : 'true'

            @_eraseHighlights()
            true #Return true to let know that an end date was set
          
          #Logic group 2
          else if @_compareDates(@_options.startDate, @_options.endDate, ">")
            @element.find("."+@options.boxClass.fullDay).each -> #Apply status classes to in-between dates
              amChild = $(@).find('.'+_this.options.boxClass.am)
              pmChild = $(@).find('.'+_this.options.boxClass.pm)

              # This conditional block is only in charge of registering whether it's the start or end of the date range
              # SET START DATE WHICH IS REALLY THE SECOND CLICK
              if _this._compareDates(_this._options.endDate, $(@).attr('data-date') + pos, '==')
                # AM END
                if pos is "T00:00:00"
                  amOToken = _this._startRangeLogic(amChild, 'start')

                # PM END
                else
                  pmOToken = _this._startRangeLogic(pmChild, 'start')

              # SET END DATE WHICH IS REALLY THE FIRST CLICK
              if _this._compareDates(_this._options.startDate, $(@).attr('data-date') + startPos, '==')
                # AM START
                if startPos is "T00:00:00"
                  amOToken = _this._endRangeLogic(amChild, 'end')
                
                # PM START
                else
                  pmOToken = _this._endRangeLogic(pmChild, 'end')

              if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T00:00:00", ">") and _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T12:00:00", "<")
                if _this._trackable(amChild) # Only add class if it's trackable
                  amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.am[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'false'

                  amChild.attr('data-range-place', 'in-between') unless amOToken

                if _this._trackable(pmChild) # Only add class if it's trackable
                  pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.pm[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'false'
                    
                  pmChild.attr('data-range-place', 'in-between') unless pmOToken

              else if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T00:00:00", "==")
                if _this._trackable(amChild) # Only add class if it's trackable
                  amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'true'

              else if _this._compareDates(_this._options.endDate, $(@).attr("data-date") + "T12:00:00", "==")
                if _this._trackable(pmChild) # Only add class if it's trackable
                  pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'true'

            @_eraseHighlights()
            true #Return true to let know that an end date was set
          
          #Logic group 3
          else
            @element.find("."+@options.boxClass.fullDay).each -> #Apply status classes to in-between dates
              amChild = $(@).find('.'+_this.options.boxClass.am)
              pmChild = $(@).find('.'+_this.options.boxClass.pm)

              # This conditional block is only in charge of registering whether it's the start or end of the date range
              if _this._compareDates(_this._options.startDate, $(@).attr('data-date') + startPos, '==')
                # AM DATE
                if startPos is "T00:00:00"
                  _this._startEndRangeLogic(amChild)

                # PM DATE
                else
                  _this._startEndRangeLogic(pmChild)

              if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T00:00:00", "==")
                if _this._trackable(amChild) # Only add class if it's trackable
                  amChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.am.delimiter + " " + _this.options.setStates.am[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'true'

              else if _this._compareDates(_this._options.startDate, $(@).attr("data-date") + "T12:00:00", "==")
                if _this._trackable(pmChild) # Only add class if it's trackable
                  pmChild.removeClass(_this._getAllClasses(_this.options.setStates))
                  .addClass(_this.options.setStates.pm.delimiter + " " + _this.options.setStates.pm[_this._options.state]) 
                  .attr
                    'data-status-type'  : _this._options.state
                    'data-delimiter'    : 'true'
          
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
            place     : ""
          pm          : 
            type      : @options.defaultStatusType
            delimiter : "false"
            place     : ""
        }

        # Perform some date formating modifications so that it plays nice with the Date object
        fulldate = "#{year}-#{@_pad(parseInt(month)+1,2)}-#{@_pad(i+1,2)}"

        # If we have loaded data, we match it up
        if @_options.loadedData.availability?
          for status in @_options.loadedData.availability
            if status.date is fulldate+"T00:00:00"
              states.am.type       = status.type
              states.am.delimiter  = status.delimiter
              states.am.place      = if typeof status.place isnt "undefined" then status.place else ""
            else if status.date is fulldate+"T12:00:00"
              states.pm.type       = status.type
              states.pm.delimiter  = status.delimiter
              states.pm.place      = if typeof status.place isnt "undefined" then status.place else ""

        # Create day DOM element
        dayshtml += """
                    <div class="#{@options.boxClass.fullDay} #{@options.trackClass}" data-date="#{fulldate}">
                      <div class="#{@options.boxClass.am} #{@options.setStates.am[states.am.type]} #{if states.am.delimiter is "true" then @options.setStates.am.delimiter else ""}" data-date="#{fulldate}T00:00:00" data-status-type="#{states.am.type}" data-delimiter="#{states.am.delimiter}" data-range-place="#{states.am.place}">
                        <div class="#{@options.boxClass.pm} #{@options.setStates.pm[states.pm.type]} #{if states.pm.delimiter is "true" then @options.setStates.pm.delimiter else ""}" data-date="#{fulldate}T12:00:00" data-status-type="#{states.pm.type}" data-delimiter="#{states.pm.delimiter}" data-range-place="#{states.pm.place}">
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

    _getMonthsByPeriod: (year, month, period, display = true) -> 
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
        @_setDisplayedMonths(date[0], date[1], movement) if display

      html

    _splitDate: (index, source) ->
      date = source[index].split("-")
      i = 0
      while i < date.length
        date[i] = parseInt(date[i])
        i++
      date

    # Load previous months into the DOM
    _loadPrevMonths: (period) ->
      switch @options.scrollDirection
        when "vertical"
          currentpos = @_parseMargin(@element.find('.slider_container').css('marginTop'))
          rowheight = @element.find('.month_box').outerHeight(true)
          rows = (period / @options.monthScrollPeriod)
          
          date = @_splitDate(0, @_options.loadedMonths)
          html = @_getMonthsByPeriod(date[0],date[1],-period, false)
          if html.length > 0
            @element.find('.slider_container')
                    .prepend(html)
                    .css("marginTop" : -(rowheight * rows)+"px")
        else
          currentpos = @_parseMargin(@element.find('.slider_container').css('marginLeft'))
          colwidth = @element.find('.month_box').outerWidth(true)
          cols = (period / @options.monthScrollPeriod)
          
          date = @_splitDate(0, @_options.loadedMonths)
          html = @_getMonthsByPeriod(date[0],date[1],-period, false)
          if html.length > 0
            @element.find('.slider_container')
                    .prepend(html)
                    .css("marginLeft" : -(colwidth * cols)+"px")

    _getBiggestDate : (array) ->
      transformed = []
      for date in array
        date = date.split('-')
        transformed.push( new Date( Date.UTC(date[0], date[1]) ).getTime() )
      
      result = Math.max.apply( Math, transformed )
      new Date(result).getUTCFullYear() + "-" + new Date(result).getUTCMonth()

    # Load next months into DOM
    _loadNextMonths: (period) ->
      switch @options.scrollDirection
        when "vertical"
          # get largest date
          date = @_splitDate(0, [@_getBiggestDate(@_options.loadedMonths)])

          @element.find('.slider_container')
                  .append(@_getMonthsByPeriod(date[0],date[1],period, false))
        else

          # get largest date
          date = @_splitDate(0, [@_getBiggestDate(@_options.loadedMonths)])
          @element.find('.slider_container')
                  .append(@_getMonthsByPeriod(date[0],date[1],period, false))

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
      if @options.mode is "datePicker"
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

      @_track() if @options.track
      
    _create: ->
      # Store widget instance in array
      $.a07.BearCal.instances.push(@element)

      _this = @

      # Create per instance copy of "private" object
      @_options = $.extend(true, {}, @_options)

      # Check to see if we should load some JSON data
      if @options.json.enable
        $.getJSON @options.json.url, (data) ->

          # Check to see if the data needs to be prepared
          if _this.options.json.type is "range"
            data = _this._prepareRange(data)

          $.extend(_this._options.loadedData, data)

          _this._startup() #This needs to be here, in the successful callback since it's asynchronous
      else
        _this._startup()

    _UTCify : (date) ->
      year = date.slice(0,4)
      month = date.slice(5,7)
      month--
      day = date.slice(8,10)
      hour = date.slice(11,13)
      min = date.slice(14,16)
      sec = date.slice(17,19)

      Date.UTC(year, month, day, hour, min, sec)

    # Take a date range an explode it into a halfday by halfday 
    _prepareRange: (data) ->
      tmp = { availability: [] }
      
      for day in data.availability
        if day.place is "start" or day.place is "start-end"
          tmp.availability.push({
            date      : day.date
            delimiter : day.delimiter
            place     : day.place
            type      : day.type
          })
        else if day.place is "end"
          startDate = new Date ( @_UTCify(tmp.availability[tmp.availability.length-1].date) )
          endDate = new Date ( @_UTCify(day.date) )

          while endDate.getTime() > startDate.getTime()
            startDate = new Date( startDate.getTime() + 43200000)
            date = @_prepareDate(startDate)
            tmp.availability.push({
              date      : date
              delimiter : "false"
              place     : "in-between"
              type      : day.type
            })

          tmp.availability[tmp.availability.length-1].delimiter = day.delimiter
          tmp.availability[tmp.availability.length-1].place = day.place

      tmp # Return prepared range

    # Convert date object to our date string standard
    _prepareDate: (date) ->
      pad = (n) ->
        (if n < 10 then "0" + n else n)
      date.getUTCFullYear() + "-" + pad(date.getUTCMonth() + 1) + "-" + pad(date.getUTCDate()) + "T" + pad(date.getUTCHours()) + ":" + pad(date.getUTCMinutes()) + ":" + pad(date.getUTCSeconds())

    _getNextDateDOMObj: (date) ->
      time = new Date( @_UTCify(date) ).getTime()
      newDate = @_prepareDate(new Date(time + 43200000))
      $('.'+@options.trackClass+' div[data-date="'+newDate+'"]')

    _getPrevDateDOMObj: (date) ->
      time = new Date( @_UTCify(date) ).getTime()
      newDate = @_prepareDate(new Date(time - 43200000))
      $('.'+@options.trackClass+' div[data-date="'+newDate+'"]')

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

  $.fn.reverse = [].reverse

) jQuery, window, document
