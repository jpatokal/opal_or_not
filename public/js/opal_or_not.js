google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(initChart);

var chart;
var options;
var submitButtonHtml = $('form button.compare').html();
var directionsService = new google.maps.DirectionsService();

var cityStations = [
  'Central (Sydney)', 'Town Hall', 'Wynyard', 'Circular Quay',
  'Martin Place', 'Kings Cross', 'St. James', 'Museum'
];

// Open/close second trip segment
$('form').on('click', 'button.transfer', function() {
	$('.segment-2').toggleClass('hidden');
  $('.transfer.btn').toggleClass('hidden');
});

function hasTransfer() {
  return (! $('.segment-2').hasClass('hidden'));
}

// Update zone options when mode changes
function selectModeHandler(segment) {
  $('form').on('change', segment + ' .mode', function() {
    var selectedMode = $('form ' + segment + ' .mode').val();
    ['bus', 'ferry', 'train'].map( function(mode) {
      if(mode == selectedMode) {
        $(segment + ' .selector.' + mode).removeClass('hidden');
      } else {
        $(segment + ' .selector.' + mode).addClass('hidden');
      }
    });
  });
}
selectModeHandler('.segment-1');
selectModeHandler('.segment-2');
$('form .segment-1 select.destination').val('Central (Sydney)');

// Compute fares
$('form').on('click', 'button.compare', function() {
  $('.alert').addClass('hidden');
  $('button.compare').html('Calculating... <i class="fa fa-spinner fa-spin"/>').attr('disabled', true);

  var mode1 = $('form .segment-1 .mode').val();
  var mode2 = $('form .segment-2 .mode').val();
  if(mode1 == 'train') {
    if(hasTransfer() && mode2 == 'train') {
      error('No need to specify train transfers, just enter origin and final destination.');
      return;
    }
    getTrainDistance(
      $('form .segment-1 select.origin').val(),
      $('form .segment-1 select.destination').val(), 1);
    return; // async
  } else {
    if(hasTransfer() && mode2 == 'train') {
      getTrainDistance(
        $('form .segment-2 select.origin').val(),
        $('form .segment-2 select.destination').val(), 2);
      return; // async 
    }
  }
  // else
  doSubmit();
});

function collectData(segment) {
  var mode = $('form ' + segment + ' .mode').val();
  return { "mode": mode,
           "zone": $('form ' + segment + ' .zone.' + mode).val(),
           "count": $('form .count').val(),
           "time": {
             "am": $('form ' + segment + ' .am').val(),
             "pm": $('form ' + segment + ' .pm').val()
           }};
}

function doSubmit() {
  var data = [ collectData('.segment-1') ]
  if(hasTransfer()) {
    data.push(collectData('.segment-2'));
  }
  jsonData = JSON.stringify(data);

  jqXhr = $.post("/compute", jsonData).done( function(data) {
    json = JSON.parse(data);
    if(json.winner == 'Opal') {
      $(".opal-wins").removeClass('hidden');
      $(".opal-loses").addClass('hidden');
    } else {
      $(".opal-wins").addClass('hidden');
      $(".opal-loses").removeClass('hidden');
    }
    $('.winner').text(json.winner);
    $('.alternative').text(json.alternative);
    $('.weekly-savings').text("$" + json.savings.week.toFixed(2));
    $('.yearly-savings').text("$" + json.savings.year.toFixed(2));
    $('span.count').text(json.stats.count);
    $('span.opal-percent').text(json.stats.Opal.percent);
    if(json.stats.Opal.average) {
      $('span.opal-average').text("$" + json.stats.Opal.average.toFixed(2));
    }
    $('span.non-opal-percent').text(json.stats.NonOpal.percent);
    if(json.stats.NonOpal.average) {
      $('span.non-opal-average').text("$" + json.stats.NonOpal.average.toFixed(2));
    }
    $('.results').removeClass('hidden');
    drawChart(json.table);
    $('.social').addClass('social-likes').socialLikes(); // lazy load
    goToByScroll("results");
  });
  jqXhr.fail( function(data) {
    error();
  });
  jqXhr.always( function(data) {
    $('button.compare').html(submitButtonHtml).removeAttr('disabled');
  });
}

function goToByScroll(id){
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'slow');
}

// This would make more sense to do in the backend, but Google's quotas are
// much more generous for client-side JS requests.
function getTrainDistance(origin, destination, segment) {
  // Tomorrow 9 AM, when train schedule is at its busiest
  var rushHour = new Date();
  rushHour.setDate(rushHour.getDate() + 1);
  rushHour.setHours(9,0,0,0);
  var request = {
      origin: origin + " station, NSW",
      destination: destination + " station, NSW",
      transitOptions: {
        departureTime: rushHour
      },
      travelMode: google.maps.TravelMode.TRANSIT
  };
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      // Find first 'leg' where all 'steps' are WALKING or TRANSIT..HEAVY_RAIL
      var foundValidLeg = false;
      for(i = 0; i < response.routes[0].legs.length; i++) {
        var leg = response.routes[0].legs[i];
        var validLeg = true;
        for(j = 0; j < leg.steps.length; j++) {
          var mode = leg.steps[j].travel_mode;
          console.log(i, j, mode, leg.steps[j].instructions);
          if(mode == "TRANSIT") {
            if(leg.steps[j].transit.line.vehicle.type != "HEAVY_RAIL") {
              validLeg = false;
            }
          }
        }
        if(validLeg) {
          foundValidLeg = true;
          break;
        } else {
          console.log('invalid', i);
        }
      }
      if(foundValidLeg) {
        var distance = response.routes[0].legs[i].distance.value / 1000;
        console.log('valid', i, distance);
        // Add 2 km fudge factor for journeys to/from city core
        // https://github.com/jpatokal/opal_or_not/issues/2
        if(isCityStation(origin) || isCityStation(destination)) {
          distance = distance + 2.0;
          console.log('Adding fudge factor, new distance', distance);
        }
        distanceToTrainZone(distance, segment);
      } else {
        error("Sorry, couldn't work out a sensible route between those two stations.  <a href='/faq#trybus'>Try a bus instead?</a>");
      }
    } else {
      error();
    }
  });
}

function isCityStation(name) {
  return ($.inArray(name, cityStations) > -1);
}

function distanceToTrainZone(distance, segment) {
  var zone;
  if(distance < 10) {
    zone = 1;
  } else if (distance > 10 && distance < 20) {
    zone = 2;
  } else if (distance > 20 && distance < 35) {
    zone = 3;
  } else if (distance > 35 && distance < 65) {
    zone = 4;
  } else {
    zone = 5;
  }
  $('form .segment-' + segment + ' .zone.train').val(zone);
  doSubmit();
}

function error(message) {
  if(! message) {
    message = "Sorry, something went wrong.  If this keeps happening, please take a screenshot " +
      "and <a href='https://github.com/jpatokal/opal_or_not/issues'>file a bug</a>.";
  }
  $('.alert').html(message).removeClass('hidden');
  $('button.compare').html(submitButtonHtml).removeAttr('disabled');
}

function initChart() {
  var initial_data = [
    ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
    ['Opal', 1, 'gray', '$0.00' ],
    ['TravelTen', 1, 'gray', '$0.00' ],
    ['MyMulti', 1, 'gray', '$0.00' ],
  ];
  chart = new google.visualization.BarChart(document.getElementById('bar-chart'));
  options = {
    animation: { duration: 500, easing: "out" },
    chartArea: { left: 0, top: 10, height: 140 },
    fontName: 'Georgia,"Times New Roman",Times,serif',
    fontSize: 16,
    hAxis: { gridlines: { count: 0 }, minValue: 0, ticks: [] },
    vAxis: { textPosition: "in", textStyle: {color: 'white', auraColor: 'none' } },
    legend: { position: "none" },
    tooltip: { trigger: "none" }
  };
  $('.results').removeClass('hidden');
  drawChart(initial_data);
  // Chart cannot be drawn on hidden div
  $('.results').addClass('hidden');
}

function drawChart(data) {
  table = google.visualization.arrayToDataTable(data);
  chart.draw(table, options);
}
