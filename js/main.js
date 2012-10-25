$(function() {
  $('.bearcal').BearCal({
    monthScrollPeriod  : 4,
    json          : true,
    jsonUrl       : "/sample-data-large.json"
  });

  $('.minibearcal').BearCal({
    period        : 1,
    nthMonth      : 1,
    monthScrollPeriod  : 1,
    json          : true,
    jsonUrl       : "/sample-data-large.json"
  });
});
