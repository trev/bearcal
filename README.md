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
* ####startDate
What date to start the calendar from. Takes a date object or properly formated date object string.
Default: Today's date
period            : 12
scrollPeriod      : 4
monthFullName     : ['January','February','March','April','May','June','July','August','September','October','November','December']
days              : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
nthMonth          : 4
nthMonthClass     : "endrow"
animateSpeed      : 500
nextMonthsHtml    : -> "<a href=\"#\" class=\"next_months\">Next #{@scrollPeriod} months</a>"
prevMonthsHtml    : -> "<a href=\"#\" class=\"prev_months\">Previous #{@scrollPeriod} months</a>"
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
