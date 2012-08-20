(($, window, document) ->
  $.widget "a07.BearCal",
  options:
    startDate     : new Date()
    period        : 12
    monthFullName : ['January','February','March','April','May','June','July','August','September','October','November','December']
    day           : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']

  _getRowCount: ->
    
  _prepDate: ->
    if typeof this.options.startDate isnt "object"
      date = this.options.startDate.split('/')
      this.options.startDate = new Date(date[0], date[1], date[2])
  
  _getFirstDayOfMonth: ->
    this.options.startDate.getDay()

  _create: ->

  _init: ->
    this._prepDate()

  destroy: ->

  _setOption: (key, value) ->


  getPeriod: ->
    this.options.period

) jQuery, window, document
