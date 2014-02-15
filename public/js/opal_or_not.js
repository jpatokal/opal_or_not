google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(initChart);

var chart;
var options;

$('form').on('click', 'button.transfer', function() {
	$('.segment-2').toggleClass('hidden');
  $('.transfer.btn').toggleClass('hidden');
});

$('form').on('click', 'button.compare', function() {
  $('.spinner').removeClass('hidden');
  $('.results').addClass('hidden');

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
  console.log(tripData);

  $.post("/compute", tripData).done( function(data) {
      console.log("IN ", data)
      $('.spinner').addClass('hidden');
      $('.results').removeClass('hidden');
      drawChart(data.chart);
    });
});

function initChart() {
  var data = google.visualization.arrayToDataTable([
    ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
    ['Opal', 10, 'gray', '$0.00' ],
    ['MyMulti', 10, 'gray', '$0.00' ],
    ['TravelTen', 10, 'gray', '$0.00' ],
    ['Weekly', 10, 'gray', '$0.00' ],
  ]);
  chart = new google.visualization.BarChart(document.getElementById('bar-chart'));
  options = {
    animation: { duration: 500 },
    fontName: 'Georgia,"Times New Roman",Times,serif',
    fontSize: 20,
    hAxis: { gridlines: { count: 0 }, minValue: 0, ticks: [] },
    legend: { position: "none" }
  };
  chart.draw(data, options);
  // Chart cannot be drawn on hidden div
  $('.results').addClass('hidden');
}

function drawChart(data) {
  var data = google.visualization.arrayToDataTable([
    ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ],
    ['Opal', 28.94, 'gray', '$28.94' ],
    ['MyMulti', 20.49, 'gray', '$20.49' ],
    ['TravelTen', 19.30, '#4582EC', '$19.30 ✓' ],
    ['Weekly', 21.45, 'gray', '$21.45' ],
  ]);
  chart.draw(data, options);
}
