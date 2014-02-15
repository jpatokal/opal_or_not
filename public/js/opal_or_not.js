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
  console.log(! $('.segment-2').hasClass('hidden'));
  if(! $('.segment-2').hasClass('hidden')) {
    data.push({
      "mode": $('form .segment-2 .mode').val(),
      "zone": $('form .segment-2 .zone').val(),
      "count": $('form .count').val()
    });
  }
  console.log(JSON.stringify(data));

  setTimeout(function() {
    $('.spinner').addClass('hidden');
    $('.results').removeClass('hidden');
  }, 1000);
});
