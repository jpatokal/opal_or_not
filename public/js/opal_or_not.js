google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(initChart);

var chart;
var options;
var submit_button_html = $('form button.compare').html();
var directionsService = new google.maps.DirectionsService();

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
$('form .segment-1 select.destination').val('Central');

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

function doSubmit() {
  var mode = $('form .segment-1 .mode').val();
  var data = [
    { "mode": mode,
      "zone": $('form .segment-1 .zone.' + mode).val(),
      "count": $('form .count').val() }
  ];
  if(hasTransfer()) {
    mode = $('form .segment-2 .mode').val();
    data.push({
      "mode": mode,
      "zone": $('form .segment-2 .zone.' + mode).val(),
      "count": $('form .count').val()
    });
  }
  tripData = JSON.stringify(data);

  jqXhr = $.post("/compute", tripData).done( function(data) {
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
    $('span.opal-sum').text(json.stats.Opal.sum.toFixed(2));
    $('span.non-opal-percent').text(json.stats.NonOpal.percent);
    $('span.non-opal-sum').text(json.stats.NonOpal.sum.toFixed(2));
    $('.results').removeClass('hidden');
    drawChart(json.table);
    $('.social').addClass('social-likes').socialLikes(); // lazy load
    goToByScroll("results");
  });
  jqXhr.always( function(data) {
    $('button.compare').html(submit_button_html).removeAttr('disabled');
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
      origin: origin + " train station, NSW",
      destination: destination + " train station, NSW",
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
        distanceToTrainZone(distance, segment);
      } else {
        error("Sorry, couldn't work out a sensible route between those two stations.  Try a bus instead?");
      }
    } else {
      error();
    }
  });
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
    message = "Sorry, something went wrong.  If this keeps happening, please file a bug.";
  }
  $('.alert').text(message).removeClass('hidden');
  $('button.compare').html(submit_button_html).removeAttr('disabled');
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
    fontSize: 20,
    hAxis: { gridlines: { count: 0 }, minValue: 0, ticks: [] },
    vAxis: { textPosition: "in", textStyle: {color: 'white', auraColor: 'gray' } },
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
