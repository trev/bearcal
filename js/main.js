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
    period        : 1,
    nthMonth      : 1,
    monthScrollPeriod  : 1,
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
    mode        : "datePicker",
    json          : true,
    jsonUrl       : "/sample-data-large.json",
    datePicked  : function(e,data) {
      data.inputElem.val(data.date);
      data.parentElem.hide();
    }
  });
});
