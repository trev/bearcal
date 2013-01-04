# BearCal
![This is the Bear Dog](http://bearcal.a07.com.au/img/screenshot.jpg)

## Demo
'cause reading comes later
[BearCal demo](http://bearcal.a07.com.au)

## Description
*BearCal* is a jQuery Widget Factory plugin that produces an interactive calendar.

## So what? There are a ton of these?
Yes, too right, but this one is a bit different.

* Half-day tracking functionality (AM/PM)
* 2 Built-in Calendar Modes
    * Interactive date range selection
    * Standard date picker
* Next/Prev slide animation to view more months
    * Vertical or horizontal
* Popup calendar and placement
* Reverse state highlighting (i.e: If a selection is available, the mouse hover & highlight will be the opposite: unavailable)
* Do not track states (i.e: If a selection is a booking you might not want it to be overridden)
* Prepopulate calendar with JSON
    * By every half day
    * By date range
* Get current calendar state in JSON
    * By every half day
    * By date range
* Highly customizeable
* And more... I just don't feel like writting it all out just yet  

## Customize
*BearCal* has many configurable options and relies heavily on CSS for styling and interaction

### Options

#### startDate
What date to start the calendar from. Takes a date object or properly formated date object string.  
**Default:** Today's date  
`startDate : new Date()`

#### period
How many months to prepare initially  
**Default:** 12  
`period : 12`

#### monthScrollPeriod
How many months to load/display each time next/prev months is triggered  
**Default:** 4  
`monthScrollPeriod : 4`

#### yearScrollPeriod
How many months to load/display each time next/prev year is triggered  
**Default:** 4  
`yearScrollPeriod : 12`

#### monthFullName
Array of month names to use  
**Default:** All 12 full months in english  
`monthFullName : ['January','February','March','April','May','June','July','August','September','October','November','December']`

#### days
Array of day names to use  
**Default:** All 7 days of the week in english  
`days : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']`

#### nthMonth
Apply the class as defined in *nthMonthClass* after n many months  
**Default:** 4  
`nthMonth : 4`

#### nthMonthClass
Name of the class to apply after *nthMonth*  
**Default:** endrow  
`nthMonthClass : "endrow"`

#### animateSpeed
Animate speed for the prev/next action  
**Default:** 500ms  
`animateSpeed : 500`

#### nextPeriodHtml
HTML for the next period DOM elements  
**Default:** A function returning an anchor element and *scrollPeriod* details  
`nextMonthsHtml : function() { return "<a href=\"#\" class=\"next_months\">Next #{@monthScrollPeriod} months</a><a href=\"#\" class=\"next_year\">Next #{@yearScrollPeriod} months</a>" }`

#### prevPeriodHtml
HTML for the previous period DOM elements  
**Default:** A function returning an anchor element and *scrollPeriod* details  
`prevMonthsHtml : function() { return "<a href=\"#\" class=\"prev_year\">Previous #{@yearScrollPeriod} months</a><a href=\"#\" class=\"prev_months\">Previous #{@monthScrollPeriod} months</a>" }`

#### boxClass
Object literal containing the classes to apply to the wrapper div of a single day and child divs: AM and PM  
**Default:**   

    boxClass: {
      am: "am_box",
      pm: "pm_box",
      fullDay: "day_box"

#### trackClass
Class to add to each single day wrapper div. This class is used solely for attaching events.  
**Default:** track  
`trackClass : "track"`

#### defaultStatusType
The default status that is applied to the AM and PM div data-status-type attribute when none is supplied  
**Default:** available  
`defaultStatusType : "available"`


#### reverseTypes
Object literal containing the reverse/opposite states. This is used to apply the right class when you're hovering over an element. I.e: If you hover over a period that is set to available, it'll know to apply the unavailable state.  
**Default:**   

    reverseTypes: {
      available: "unavailable",
      unavailable: "available"
    }

#### hoverStates
Object literal containing which class to apply on a per period and per state basis when the mouse is only hovering.  
**Default:**   

    hoverStates: {
      am: {
        available: "hover_available_am",
        unavailable: "hover_unavailable_am"
      },
      pm: {
        available: "hover_available_pm",
        unavailable: "hover_unavailable_pm"
      }
    }

#### highlightStates
Object literal containing which class to apply on a per period and per state basis when we're highlighting a date span  
**Default:**   

    highlightStates: {
      am: {
        available: "highlight_available_am",
        unavailable: "highlight_unavailable_am"
      },
      pm: {
        available: "highlight_available_pm",
        unavailable: "highlight_unavailable_pm"
      }
    }

#### setStates
Object literal containing which class to apply on a per period and per state basis when we're saving a date span selection  
**Default:**   

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
    }

#### json
Object literal containing whether we should load data from JSON and how  
**Default:**   

    json: {
      enable: false,
      type: "all", //"all" or "range"
      url: ""
    }

#### dontTrackStates
Which states not to track. I.e: You may want to remove the ability to override DOM elements set to "booked"  
**Default:** booked  
`dontTrackStates : ["booked"]`

### API Methods
#### getJSON()
Returns the current calendar start in JSON format. Each half day of the currently loaded calendar is returned. So if you have 12 months loaded, this method will return 365x2 objects defining each half day of the year.

#### getJSONByStates(states, range=false)
Accepts 2 arguments: 
`states` must be of type Array containing strings matching the states you want to get 
`range` is an optional boolean. If set to true, getJSONbyStates will return the start and end of each range ignoring the inbetween dates. 
 
From the console (will return the unavailable and booked states grouped by date range): 

    $('.bearcal').data('BearCal').getJSONByStates(['unavailable', 'booked'], true);

#### setLiveDates(dates, range=false)
Accepts 2 arguments:  
`dates` is an object as defined below  
`range` is an optional boolean. If set to true, BearCal will take the dates object and parse it looking for ranges  
  
`dates` object format is:  

    dates = {
      availability: [{
        date: "yyyy-mm-ddTxx:xx:xx",
        delimiter: "false",
        place: "start",
        type: "unavailable"
      }, {
        ...
      }]
    }
  
Example setting a date range from console:  

    $('.bearcal').data('BearCal').setLiveDates({availability: [{date: "2015-05-01T00:00:00", delimiter: "false", place: "start", type: "unavailable"}, {date: "2015-05-10T00:00:00", delimiter: "true", place: "end", type: "unavailable"}]}, true);

### Events
#### beforebuild
Triggers before the calendar gets generated  
**Returns:** `event`

#### datePicked
Triggers when a date is picked (datePicker mode)  
**Returns:** `event` and `data` object:

    data.elem       // The actual clicked DOM element
    data.date       // The clicked date
    data.parentElem // The calendar itself
    data.inputElem  // The DOM element (usually input) that the calendar is tied to


#### startDateSet
Trigger when an start date is set (Interactive mode)  
**Returns:** `event` and `startDate`

#### endDateSet
Trigger when an end date is set (Interactive mode)  
**Returns:** `event` and `endDate`


## Usage
Create a DOM element to attach the plugin to:
    
    <div class="bearcal"></div>

Attach the plugin:
    
    $('.bearcal').BearCal(); 

## License
Copyright (C) 2012 A07(Trevor Wistaff) 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
