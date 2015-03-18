function resetScreen(){
	screensWidth = ($("#iphone").width() * 0.865) / $(document).width() * 100;
	topOffset = $("#iphone").offset()['top'] + (0.14178 * $("#iphone").height());
	leftOffset = $("#iphone").offset()['left'] + (0.07027 * $("#iphone").width());
	$(".screen").css({'width':screensWidth + "%", 'top':topOffset + "px", 'left':leftOffset + "px"});
	$("#slider").css({'top': ($("#iphone").offset()['top'] + (0.7967 * $("#iphone").height())) + 'px', 'left': (leftOffset + 5) + 'px'});
	$("#message").css({'width':(($("#iphone").width() * 0.35135) / $(document).width() * 100) + '%', 'top': ($("#iphone").offset()['top'] + (0.271 * $("#iphone").height())) + 'px', 'left': $("#iphone").offset()['left'] + (0.4351 * $("#iphone").width()) + 'px'});
}
resetScreen();
$(document).ready(function(){
	function nextScreen(){
		if(activeChild.is($(".screen").last())){
			tmp = $(".screen").first();
		} else {
			tmp = activeChild.next();
		}
		tmp.addClass("active");
		activeChild.removeClass("active");
		activeChild = tmp;
	}

	resetScreen();
	setTimeout(resetScreen, 10);
	setTimeout(resetScreen, 50);
	setTimeout(resetScreen, 100);
	var activeChild = $(".active");
	$("#slider").draggable({containment: ".screen", axis: "x", 
		stop: function(){
			nextScreen();
			$("#slider").hide();
			$("#message").show();
			$("#message").click(function(){
				nextScreen();
				$('#message').hide();
			});
		}
	});
});

window.onresize = function(){
	resetScreen();
	resetScreen();
}