(($, window, document) ->
  $.widget "a07.BearCal",
  options:
    startDate     : new Date()
    period        : 12
    monthFullName : ['January','February','March','April','May','June','July','August','September','October','November','December']
    days          : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']

  _getRowCount: ->
    
  _prepDate: ->
    if typeof @options.startDate isnt "object"
      date = @options.startDate.split('/')
      @options.startDate = new Date(date[0], date[1], date[2])
 
  # Get the day of the week from [0..6] starting on Sunday
  _getDayOfWeek: (year, month, day) ->
    new Date(year, month, day).getDay()

  # Get amount of days in a month (http://bit.ly/PaZvjH)
  _getDaysInMonth: (year, month)  ->
    new Date(year, month, 0).getDate() 

  # Generate month titles html
  _getMonthsHtml: ->
    monthshtml = ""
    year = @options.startDate.getFullYear()
    month = @options.startDate.getMonth()
    i = 0
    while i < @options.period
      if month > 11
        month = 0  
        year++

      console.log('in')
      monthshtml += """
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
    monthshtml
    
  # Generate weekday titles html
  _getWeekdaysHtml: ->
    weekdayshtml = ""
    for day in @options.days
      weekdayshtml += "<div class=\"wday_box\">#{day.charAt(0)}</div>\n"
    weekdayshtml

  _getDaysHtml: (year, month) ->
    dayshtml = ""
    daycount = 0
    rowcount = 0
    
    # Find out what position to start first day on, so we can append blanks
    blanks = @options.startDate.getDay() 
    if blanks > 0
      i = 0
      while i < blanks
        dayshtml += "<div class=\"empty_day_box\"></div>"
        daycount++
        i++

    # Start adding days
    i = 0
    while i < @_getDaysInMonth(year,month)
      rowcount++ if daycount % 6 is 0
      dayshtml += "<div class=\"day_box\" rel=\"\">#{i+1}</div>\n"
      daycount++
      i++

    # Ensure there are atleast 7 rows so that each month is the same size
    if rowcount < 7
      #Find out how many more empty days we need to add in order to achieve 7 rows
      empties = ((6 - rowcount) * 7) + (7- @_getDayOfWeek(year, month, i))
      j = 0
      while j < empties
        dayshtml += "<div class=\"empty_day_box\"></div>"
        j++

    dayshtml

  _buildCalendar: ->

  _create: ->
    console.log(@options.startDate)
    console.log(@_getMonthsHtml())

  _init: ->
    @_prepDate()

  destroy: ->

  _setOption: (key, value) ->


  getPeriod: ->
    @options.period

) jQuery, window, document
