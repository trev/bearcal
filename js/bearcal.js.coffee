(($, window, document) ->
  $.widget "a07.BearCal",
  options:
    startDate     : new Date()
    period        : 12
    monthFullName : ['January','February','March','April','May','June','July','August','September','October','November','December']
    days          : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']

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

  _getCalendar: ->
    calendarhtml = "<div class=\"year_box\">"
    year = @options.startDate.getFullYear()
    month = @options.startDate.getMonth()
    i = 0
    while i < @options.period
      # Track year change and react accordingly
      if month > 11 
        month = 0  
        year++

      calendarhtml += """
                  <div class="month_box">
                    <div class="month_header">#{@options.monthFullName[month]} #{year}</div>
                    <div class="month_wrapper">
                      #{@_getWeekdaysHtml()}
                      #{@_getDaysHtml(year, month)}
                    </div>
                  </div>
                  """
      month++
      i++

    calendarhtml += "</div>"

  _create: ->
    @element.append(@_getCalendar())

  _init: ->
    @_setDate()

  destroy: ->

  _setOption: (key, value) ->


  getPeriod: ->
    @options.period

) jQuery, window, document
