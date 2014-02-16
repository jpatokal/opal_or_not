google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(initChart);

var chart;
var options;
var submit_button_html = $('form button.compare').html();

$('form').on('click', 'button.transfer', function() {
	$('.segment-2').toggleClass('hidden');
  $('.transfer.btn').toggleClass('hidden');
});

$('form').on('click', 'button.compare', function() {
  $('button.compare').html('Calculating... <i class="fa fa-spinner fa-spin"/>').attr('disabled', true);

  var data = [
    { "mode": $('form .segment-1 .mode').val(),
      "zone": $('form .segment-1 .zone').val(),
      "count": $('form .count').val() }
  ];
  if(! $('.segment-2').hasClass('hidden')) {
    data.push({
      "mode": $('form .segment-2 .mode').val(),
      "zone": $('form .segment-2 .zone').val(),
      "count": $('form .count').val()
    });
  }
  tripData = JSON.stringify(data);

  jqXhr = $.post("/compute", tripData).done( function(data) {
      json = JSON.parse(data);
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
    animation: { duration: 500 },
    fontName: 'Georgia,"Times New Roman",Times,serif',
    fontSize: 20,
    hAxis: { gridlines: { count: 0 }, minValue: 0, ticks: [] },
    legend: { position: "none" }
  };
  drawChart(initial_data);
  // Chart cannot be drawn on hidden div
  $('.results').addClass('hidden');
}

function drawChart(data) {
  table = google.visualization.arrayToDataTable(data);
  chart.draw(table, options);
}
