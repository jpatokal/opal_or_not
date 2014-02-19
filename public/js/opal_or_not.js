google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(initChart);

var chart;
var options;
var submit_button_html = $('form button.compare').html();

// Open/close second trip segment
$('form').on('click', 'button.transfer', function() {
	$('.segment-2').toggleClass('hidden');
  $('.transfer.btn').toggleClass('hidden');
});

// Update zone options when mode changes
function selectModeHandler(segment) {
  $('form').on('change', segment + ' .mode', function() {
    var selectedMode = $('form ' + segment + ' .mode').val();
    ['bus', 'ferry', 'train'].map( function(mode) {
      if(mode == selectedMode) {
        $('form ' + segment + ' select.zone.' + mode).removeClass('hidden');
      } else {
        $('form ' + segment + ' select.zone.' + mode).addClass('hidden');
      }
    });
  });
}
selectModeHandler('.segment-1');
selectModeHandler('.segment-2');

// Compute fares
$('form').on('click', 'button.compare', function() {
  $('button.compare').html('Calculating... <i class="fa fa-spinner fa-spin"/>').attr('disabled', true);

  var mode = $('form .segment-1 .mode').val();
  var data = [
    { "mode": mode,
      "zone": $('form .segment-1 .zone.' + mode).val(),
      "count": $('form .count').val() }
  ];
  if(! $('.segment-2').hasClass('hidden')) {
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
    });
  jqXhr.always( function(data) {
      $('button.compare').html(submit_button_html).removeAttr('disabled');
    });
});

function initChart() {
  var initial_data = [
    ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
    ['Opal', 10, 'gray', '$0.00' ],
    ['MyMulti', 10, 'gray', '$0.00' ],
    ['TravelTen', 10, 'gray', '$0.00' ],
    ['Weekly', 10, 'gray', '$0.00' ],
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
