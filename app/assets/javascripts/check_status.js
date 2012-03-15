function check_status() {
	$.ajax({
		url: '/check_status',
		data: "",
		cache: false,
		dataType: 'json',
		success: function(data){
			if(data.status == "done"){
				$('.flash_training').html("Kenobi is finished learning all about you, and is now classifying your results. You'll be redirected soon!");
				setTimeout(check_status,2000);
			} else if(data.status == "ready") {
				window.location = "/results";
			} else {
				setTimeout(check_status,10000);
			}
		}
	});
}

$(document).ready(function() {
	if ($('.flash_training').length) {
		spinner();
		check_status();
	}
});