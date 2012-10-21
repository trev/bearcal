$(function() {
  $('.bearcal').BearCal({
    scrollPeriod  : 4,
    json          : true,
    jsonUrl       : "/sample-data-large.json"
  });

  $('.minibearcal').BearCal({
    period        : 1,
    nthMonth      : 1,
    scrollPeriod  : 1,
    json          : true,
    jsonUrl       : "/sample-data-large.json"
  });
});
