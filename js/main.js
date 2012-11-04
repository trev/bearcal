$(function() {
  $('.bearcal').BearCal({
    monthScrollPeriod  : 4,
    json          : true,
    jsonUrl       : "/sample-data-large.json",
    startDateSet  : function(event,startDate) {
      console.log(startDate);
    },
    endDateSet  : function(event,endDate) {
      console.log(endDate);
    }
  });

  $('.minibearcal').BearCal({
    period        : 1, //Preload only one month
    monthScrollPeriod  : 1, //How many months to scroll at once
    json          : true,
    jsonUrl       : "/sample-data-large.json",
    startDateSet  : function(event,startDate) {
      console.log(startDate);
    },
    endDateSet  : function(event,endDate) {
      console.log(endDate);
    }
  });

  $('.inputbearcal').BearCal({
    monthScrollPeriod: 1, //How many months to scroll at once
    mode            : "datePicker", //Show calendar in datepicker mode
    dontTrackStates : ['booked', 'unavailable'], //Dont track dates with states listed in array
    appendClass     : "vertical-datepicker", //Append custom class to calendar
    json            : true,
    jsonUrl         : "/sample-data-large.json",
    datePicked      : function(e,data) {
      data.inputElem.val(data.date);
      data.parentElem.hide();
    }
  });

  $('.inputbearcal-horizontal').BearCal({
    monthScrollPeriod: 1, //How many months to scroll at once
    mode            : "datePicker", //Show calendar in datepicker mode
    dontTrackStates : ['booked', 'unavailable'], //Dont track dates with states listed in array
    json            : true,
    jsonUrl         : "/sample-data-large.json",
    appendClass     : "horizontal-datepicker", //Append custom class to calendar
    scrollDirection : "horizontal", //Set scroll direction
    datePicked      : function(e,data) {
      data.inputElem.val(data.date);
      data.parentElem.hide();
    },
    prevPeriodHtml  : function() {
      return "<div class=\"cal-nav clearfix\"><a href=\"#\" class=\"prev_year\"><<</a> <a href=\"#\" class=\"prev_months\"><</a>";
    },
    nextPeriodHtml  : function() {
      return "<a href=\"#\" class=\"next_year\">>></a> <a href=\"#\" class=\"next_months\">></a></div>";
    }
  });
});
