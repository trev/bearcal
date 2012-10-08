# BearCal
![This is the Bear Dog](http://a07.com.au/github/bear-hair.jpg)

## Description
*BearCal* is a jQuery Widget Factory plugin that produces an interactive calendar.

## So what? There are a ton of these?
Yes, too right, but this one is a bit different.

* Half-day tracking functionality (AM/PM)
* Interactive date range selection
* Next/Prev slide animation to view more months
* Reverse state highlighting (i.e: If a selection is available, the mouse hover & highlight will be the opposite: unavailable)
* Do not track states (i.e: If a selection is a booking you might not want it to be overridden)
* Prepopulate calendar with JSON
* Get current calendar state in JSON
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

#### scrollPeriod
How many months to load/display each time next/prev is triggered  
**Default:** 4  
`scrollPeriod : 4`


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
Animate speed for the prev/next months action  
**Default:** 500ms  
`animateSpeed : 500`

#### nextMonthsHtml
HTML for the next months DOM element  
**Default:** A function returning an anchor element and *scrollPeriod* details  
`nextMonthsHtml : function() { return "<a href=\"#\" class=\"next_months\">Next #{this.scrollPeriod} months</a>" }`

#### prevMonthsHtml
HTML for the previous months DOM element  
**Default:** A function returning an anchor element and *scrollPeriod* details  
`prevMonthsHtml : function() { return "<a href=\"#\" class=\"prev_months\">Previous #{this.scrollPeriod} months</a>" }`

#### boxClass
Object literal containing the classes to apply to the wrapper div of a single day and child divs: AM and PM

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

    reverseTypes: {
      available: "unavailable",
      unavailable: "available"
    }

#### hoverStates
Object literal containing which class to apply on a per period and per state basis when the mouse is only hovering.

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
Boolean whether we're preloading data into the calendar using JSON  
**Default:** false  
`json : false`

#### jsonUrl
URL to json data to use for preloading the calendar  
**Default:** ""  
`jsonUrl : ""`

#### dontTrackStates
Which states not to track. I.e: You may want to remove the ability to override DOM elements set to "booked"  
**Default:** booked  
`dontTrackStates : ["booked"]`

### Events
#### beforebuild
Triggers before the calendar gets generated

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
