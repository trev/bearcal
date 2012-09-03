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

  _options:
    loadedMonths      : [] 
    displayedMonths   : []

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
    new Date(year, month, 0).getDate() 

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

    # Start adding days and track how many rows we've made
    i = 0
    while i < @_getDaysInMonth(year,month)
      dayshtml += "<div class=\"day_box\" rel=\"#{year}-#{month}-#{i+1}\">#{i+1}</div>\n"
      daycount++
      i++

    # Ensure there are 42 day boxes to ensure each month is the same size
    while daycount < 42
      dayshtml += "<div class=\"empty_day_box\"></div>"
      daycount++

    dayshtml

  _getMonth: (year, month) ->
    # Track loaded months
    @_setLoadedMonths(year, month)

    # Track displayed months only if there are less months then the display period
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


      
  _dateCompare : (a, b) ->
    a = a.split("-");
    b = b.split("-");
    (new Date(a[0], a[1]).getTime()) - (new Date(b[0], b[1]).getTime())
    
  _getCalendar: ->
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

  _create: ->
    @element.append @_getCalendar()

    $('.prev_months').click =>
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

      return false

    $('.next_months').click =>
      if !$('.slider_container').is(':animated')
        currentpos = parseFloat($('.slider_container').css("marginTop"))
        rowheight = $('.month_box').outerHeight(true)
        rows = (@options.scrollPeriod / @options.nthMonth)
        animatemargin = currentpos - (rowheight * rows) 

        date = @_splitDate(@_options.displayedMonths.length-1, @_options.displayedMonths)
        $('.slider_container').append(@_getMonthsByPeriod(date[0],date[1],@options.scrollPeriod))
                              .animate({marginTop: animatemargin+"px"}, @options.animateSpeed)
      return false

  _init: ->
    @_setDate()

  destroy: ->

  _setOption: (key, value) ->


  getPeriod: ->
    @options.period

) jQuery, window, document
