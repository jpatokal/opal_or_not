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

// Compute fares
$('form').on('click', 'button.compare', function() {
  $('button.compare').html('Calculating... <i class="fa fa-spinner fa-spin"/>').attr('disabled', true);

  if($('form .segment-1 .mode').val() == 'train') {
    getTrainDistance(
      $('form .segment-1 select.origin').val(),
      $('form .segment-1 select.destination').val(), 1);
    return; // async
  } else {
    if(hasTransfer && $('.segment-2 .mode').val() == 'train') {
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
      $('.weekly-savings').text("$" + Math.abs(json.savings.week).toFixed(2));
      $('.yearly-savings').text("$" + Math.abs(json.savings.year).toFixed(2));
      $('.results').removeClass('hidden');
      drawChart(json.table);
      window.location.href = "#results";
    });
  jqXhr.always( function(data) {
      $('button.compare').html(submit_button_html).removeAttr('disabled');
    });
}

// This would make more sense to do in the backend, but Google's quotas are
// much more generous for client-side JS requests.
function getTrainDistance(origin, destination, segment) {
  var request = {
      origin: origin + " train station, Sydney, NSW",
      destination: destination + " train station, Sydney, NSW",
      transitOptions: {
        departureTime: new Date()
      },
      travelMode: google.maps.TravelMode.TRANSIT
  };
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      distanceToTrainZone(response.routes[0].legs[0].distance.value / 1000, segment);
    } else {
      // TODO something...
      console.error(status, response);
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
