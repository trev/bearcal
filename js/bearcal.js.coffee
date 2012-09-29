(($, window, document) ->
  $.widget "a07.BearCal",
  options:
    startDate         : new Date()
    period            : 12
    scrollPeriod      : 4
    monthFullName     : ['January','February','March','April','May','June','July','August','September','October','November','December']
    days              : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
    nthMonth          : 4
    nthMonthClass     : "endrow"
    animateSpeed      : 800
    dayBoxClass       : "day_box"
    trackClass        : "track"
    hoverStates       : 
      am              : "hover_am"
      pm              : "hover_pm"
      fullDay         : "hover_full_day"
    highlightStates   :
      am              : "highlight_am"
      pm              : "highlight_pm"
      fullDay         : "highlight_full_day"
    setStates         : 
      activeAm        : "active_am"
      activePm        : "active_pm"
      fullDay         : "full_day"
    availabilityTypes : 
      available       : "available"
      unavailable     : "unavailable"
      booked          : "booked"
    json              : false
    jsonUrl           : ""

  _options:
    loadedData        : {}
    loadedMonths      : [] 
    displayedMonths   : []
    startDate         : null
    endDate           : null

  # Date comparisons
  _compareDates : (s_date, e_date, operator) ->
    switch operator
      when "<" then new Date(s_date).getTime() < new Date(e_date).getTime()
      when ">" then new Date(s_date).getTime() > new Date(e_date).getTime()
      when ">=" then new Date(s_date).getTime() >= new Date(e_date).getTime()
      when "<=" then new Date(s_date).getTime() <= new Date(e_date).getTime()
      when "==" then new Date(s_date).getTime() is new Date(e_date).getTime()

  #  Tracks the events relating to calendar interactivity
  _track: ->
    _this = @
    $("."+@element.attr("class")).on
      mousemove: (event) ->

        if _this._getLocation(@, event) # We're in the upper left corner (AM)

          if !_this._highlightable() #If it's not highlightable, that means we're closing a date span

            if ~$(@).attr("class").indexOf(_this.options.setStates.activePm) # If the current square has an activePm class on it, and we're on currently in the AM section of the square(As determined earlier), we need to apply a fullDay hover class
              $(@).removeClass(_this._getAllClasses(_this.options.hoverStates)).addClass _this.options.hoverStates.fullDay
            else # If the square has no activePM class on it, we can just apply the Am hover class 
              $(@).removeClass(_this._getAllClasses(_this.options.hoverStates)).addClass _this.options.hoverStates.am

          else # It's highlightable, that means we're starting a date span
            _this._eraseHighlights() # Remove all highlight classes
            _this._trackHighlights @, "T00:00:00" # Start highlight tracking
            
        else # We're in the lower right corner (PM)
          if !_this._highlightable() #If it's not highlightable, that means we're closing a date span
            if ~$(@).attr("class").indexOf(_this.options.setStates.activeAm)
              $(@).removeClass(_this._getAllClasses(_this.options.hoverStates)).addClass _this.options.hoverStates.fullDay
            else
              $(@).removeClass(_this._getAllClasses(_this.options.hoverStates)).addClass _this.options.hoverStates.pm
          else # It's highlightable, that means we're starting a date span 
            _this._eraseHighlights() # Remove all highlight classes
            _this._trackHighlights @, "T12:00:00" # Start highlight tracking

      mouseleave: (event) ->
        $(@).removeClass _this._getAllClasses(_this.options.hoverStates) # This mouse has left the box, so we remove all highlight classes for this box. Don't worry, they get readded in the mousemove.

      click: (event) ->
        if _this._getLocation(@, event) # We're in the upper left corner (AM)
          _this._setDates(this, "T00:00:00") # Set the date as AM
          $(@).removeClass(_this._getAllClasses(_this.options.hoverStates)).addClass _this.options.setStates.activeAm # Remove all hover state classes and add the active state
        else # We're in the lower right corner (PM)
          _this._setDates(this, "T12:00:00") # Set the date as PM
          $(@).removeClass(_this._getAllClasses(_this.options.hoverStates)).addClass _this.options.setStates.activePm # Remove all hover state classes and add the adtive state

      ".day_box"

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
    $("."+@options.dayBoxClass).removeClass @_getAllClasses(@options.highlightStates)

  # Applied highlight classes defined in @options.highlightStates for AM PM or full day_box
  # while mouse is moving across the calendar
  # 
  # There are 2 logic groups - each group requires different logic
  # Group 1: If the cursor is on the left side(<) of the start date
  # Group 2: If the cursor is on the right side(>) of the start date
  #
  # Params:
  #   that: the parent event we're reacting to
  #   pos:  whether the cursor is in am or pm, valid values["T00:00:00", "T12:00:00"]
  _trackHighlights: (that, pos) ->
    _this = @
    cursorPos = $(that).attr("rel") + pos #True cursor position
    cursorAdj = $(that).attr("rel") + "T00:00:00" #Adjusted cursor position required for logic testing
    $("."+@options.dayBoxClass).each -> #Loop through all day_box(es)
      each_box = $(@).attr("rel") + "T00:00:00"
      
      #Logic group 1
      if cursorPos < _this._options.startDate
        
        #Is the current each_box between the @_options.startDate and cursor
        if _this._compareDates(each_box, cursorAdj, ">=") and _this._compareDates(each_box, _this._options.startDate, "<")
          #If cursorAdj == each_box we need to look closer to see if we need to apply halfday highlighting
          if _this._compareDates(each_box, cursorAdj, "==") and ~cursorPos.indexOf("T12:00:00")
            $(@).addClass _this.options.highlightStates.pm
          else
            $(@).addClass _this.options.highlightStates.fullDay
      
      #Logic group 2
      if cursorPos > _this._options.startDate
        
        #Is the current each_box between the @_options.startDate and cursor
        if _this._compareDates(each_box, cursorAdj, "<=") and _this._compareDates(each_box, _this._options.startDate, ">=")
          
          #If cursorAdj == each_box we need to look closer to see if we need to apply halfday highlighting
          if _this._compareDates(each_box, cursorAdj, "==") and ~cursorPos.indexOf("T00:00:00")
            $(@).addClass _this.options.highlightStates.am
          else
            $(@).addClass _this.options.highlightStates.fullDay

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
    #Are there two dates already? YES
    if @_options.startDate and @_options.endDate
      @_options.startDate = @_options.endDate = null #Erase both start & end dates
      @_options.startDate = $(that).attr("rel") + pos #Set Start date
      $("."+@options.dayBoxClass).removeClass @_getAllClasses(@options.setStates) #Remove status classes
      false
    
    #Is the start date set? YES
    else if @_options.startDate
      @_options.endDate = $(that).attr("rel") + pos #Set end date
      
      #Logic group 1
      if @_compareDates(@_options.startDate, @_options.endDate, "<")
        $("."+@options.dayBoxClass).each -> #Apply status classes to in-between dates
          $(@).attr "class", _this.options.dayBoxClass + " " + _this.options.trackClass + " " + _this.options.setStates.fullDay if _this._compareDates(_this._options.startDate, $(@).attr("rel") + "T00:00:00", "<=") and _this._compareDates(_this._options.endDate, $(@).attr("rel") + "T00:00:00", ">") #Overwrite all classes and apply status class

        @._eraseHighlights()
        true #Return true to let know that an end date was set
      
      #Logic group 2
      else if @_compareDates(@_options.startDate, @_options.endDate, ">")
        $("."+@options.dayBoxClass).each -> #Apply status classes to in-between dates
          $(@).attr "class", _this.options.dayBoxClass + " " + _this.options.trackClass + " " + _this.options.setStates.fullDay if _this._compareDates(_this._options.startDate, $(@).attr("rel") + "T00:00:00", ">") and _this._compareDates(_this._options.endDate, $(@).attr("rel") + "T00:00:00", "<=") #Overwrite all classes and apply status class

        @_eraseHighlights()
        true #Return true to let know that an end date was set
      
      #Logic group 3
      else
        true #Return true to let know that an end date was set
    
    #Other possibilities (Fresh start)
    else
      @_options.startDate = $(that).attr("rel") + pos #Set start date
      false #Return false tolet know that no end date was set

  # Return all values within an object literal
  _getAllClasses: (obj) ->
    results = ""
    $.each obj, (index, value) ->
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
    statusclass = ""
    i = 0
    while i < @_getDaysInMonth(year,month)
      # Reset
      statusclass = ""

      # Perform some date formating modifications so that it plays nice with the Date object
      fulldate = "#{year}-#{@_pad(parseInt(month)+1,2)}-#{@_pad(i+1,2)}"

      # If JSON enabled, check to see if we have to apply any extra classes to the day
      if @_options.loadedData.availability.length > 0
        for status in @_options.loadedData.availability
          if status.date is fulldate
            statusclass = "#{@options.availabilityTypes[status.type]} #{@options.setStates[status.span]}"

      # Create day DOM element
      dayshtml += "<div class=\"#{@options.dayBoxClass} #{@options.trackClass} #{statusclass}\" rel=\"#{fulldate}\">#{i+1}</div>\n"

      # Count 'em for good measure
      daycount++
      i++

    # Ensure there are 42 day boxes that way each month contains the same amount of boxes (Formatting goodness) 
    while daycount < 42
      dayshtml += "<div class=\"empty_day_box\"></div>"
      daycount++

    dayshtml

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
      <div class="month_wrapper">
        #{@_getWeekdaysHtml()}
        #{@_getDaysHtml(year, month)}
      </div>
    </div>
    """

  _setLoadedMonths: (year, month) ->
    @_options.loadedMonths.push(year + "-" + month)
    @_options.loadedMonths.sort(@_dateCompare)

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
    
  _getCalendar: ->
    # Trigger prebuild
    @_trigger("beforebuild")

    calendarhtml = "<a href=\"#\" class=\"prev_months\">Previous #{@options.scrollPeriod} Months</a>"
    calendarhtml += "<div class=\"year_box clearfix\">\n  <div class=\"slider_container clearfix\">\n"
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
    calendarhtml += "<a href=\"#\" class=\"next_months\">Next #{@options.scrollPeriod} Months</a>"

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
  _getPrevMonths: ->
    if !$('.slider_container').is(':animated')
      currentpos = parseFloat($('.slider_container').css("marginTop"))
      rowheight = $('.month_box').outerHeight(true)
      rows = (@options.scrollPeriod / @options.nthMonth)
      animatemargin = currentpos + (rowheight * rows) 

      animatemargin = if animatemargin is (rowheight * rows) then 0 else animatemargin
      
      date = @_splitDate(0, @_options.displayedMonths)
      html = @_getMonthsByPeriod(date[0],date[1],-@options.scrollPeriod)
      if html.length > 0
        $('.slider_container').prepend(html)
                              .css("marginTop" : (currentpos - (rowheight * rows))+"px")
                              .animate({marginTop: animatemargin+"px"}, @options.animateSpeed)
      else
        $('.slider_container').animate({marginTop: animatemargin+"px"}, @options.animateSpeed)

  # Gets next months and adjusts the view accordingly
  _getNextMonths: ->
    if !$('.slider_container').is(':animated')
      currentpos = parseFloat($('.slider_container').css("marginTop"))
      rowheight = $('.month_box').outerHeight(true)
      rows = (@options.scrollPeriod / @options.nthMonth)
      animatemargin = currentpos - (rowheight * rows) 

      date = @_splitDate(@_options.displayedMonths.length-1, @_options.displayedMonths)
      $('.slider_container').append(@_getMonthsByPeriod(date[0],date[1],@options.scrollPeriod))
                            .animate({marginTop: animatemargin+"px"}, @options.animateSpeed)

  _startup: ->
    @element.append @_getCalendar()

    $('.prev_months').click =>
      @_getPrevMonths()
      return false

    $('.next_months').click =>
      @_getNextMonths()
      return false

    @_track()


  _create: ->
    _this = @

    if @options.json 
      # Testing
      $.getJSON @options.jsonUrl, (data) ->
        $.extend(_this._options.loadedData, data)
        _this._startup() 
    else
      _this._startup()


  _init: ->
    _this = @

    # We call set date to ensure a Date object is passed as the options.startDate value
    @_setDate()

  destroy: ->

  _setOption: (key, value) ->

) jQuery, window, document
