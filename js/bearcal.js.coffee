(($, window, document) ->
  $.widget "a07.BearCal",
  options:
    startDate     : new Date()
    period        : 12
    scrollPeriod  : 4
    monthFullName : ['January','February','March','April','May','June','July','August','September','October','November','December']
    days          : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']

  _options:
    loadedMonths : [] 
    displayPosition: []

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
    
    # Prepare month
    """
    <div class="month_box">
      <div class="month_header">#{@options.monthFullName[month]} #{year}</div>
      <div class="month_wrapper">
        #{@_getWeekdaysHtml()}
        #{@_getDaysHtml(year, month)}
      </div>
    </div>
    """

  _setLoadedMonths: (year, month) ->
    if @_options.loadedMonths.length isnt 0
      date = @_options.loadedMonths[0].split("-")
      if new Date(year, month).getTime() < new Date(date[0], date[1]).getTime()
        @_options.loadedMonths.unshift(year + "-" + month)
      else
        @_options.loadedMonths.push(year + "-" + month)
    else
      @_options.loadedMonths.push(year + "-" + month)
    
  _getCalendar: ->
    calendarhtml = "<div class=\"prev_months\">Previous #{@options.scrollPeriod} Months</div>"
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
    calendarhtml += "<div class=\"next_months\">Next #{@options.scrollPeriod} Months</div>"

  _getMonthsByPeriod: (year, month, period) -> 
    movement = if period < 0 then -1 else 1
    i = Math.abs(period)
    results = []
    html = ""
  
    while i isnt 0
      month += movement
      tmp = month % 12
      year = if tmp is 0 then year + movement else year
      _month = if tmp < 0 then (tmp+12) else tmp
      results.push(year + "-" + _month)
      --i

    if movement is -1 then results.reverse()
    
    for result in results
      date = result.split("-")
      html += @_getMonth(date[0], date[1])

    html

  _splitDate: (index) ->
    date = @_options.loadedMonths[index].split("-")
    i = 0
    while i < date.length
      date[i] = parseInt(date[i])
      i++
    date

  _create: ->
    @element.append @_getCalendar()
    $('.prev_months').click =>
      if !$('.slider_container').is(':animated')
        height = parseFloat($('.slider_container').css("marginTop")) - $('.month_box').outerHeight(true)
        animatemargin = height + $('.month_box').outerHeight(true)
        date = @_splitDate(0)
        $('.slider_container').prepend(@_getMonthsByPeriod(date[0],date[1],-4)).css("marginTop" : height+"px").animate({marginTop: animatemargin+"px"}, 1000)

    $('.next_months').click =>
      if !$('.slider_container').is(':animated')
        height = $('.month_box').outerHeight(true) - parseFloat($('.slider_container').css("marginTop"))
        date = @_splitDate(@_options.loadedMonths.length-1)
        $('.slider_container').append(@_getMonthsByPeriod(date[0],date[1],4)).animate({marginTop: -height+"px"}, 1000)

  _init: ->
    @_setDate()

  destroy: ->

  _setOption: (key, value) ->


  getPeriod: ->
    @options.period

) jQuery, window, document
