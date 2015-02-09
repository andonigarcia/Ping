var MAP;

function initializeMap(address){
	var geocoder = new google.maps.Geocoder();
	var center
	geocoder.geocode({
		'address':address
	}, function(results, status){
		if(status != google.maps.GeocoderStatus.OK || status == google.maps.GeocoderStatus.ZERO_RESULTS){
	 		// ERROR not valid address todo
	 		return
	 	} else {
	 		var mapOptions = {
	 			center: results[0].geometry.location,
	 			zoom: 15,
	    	    disableDefaultUI: true,
	        	disableDoubleClickZoom: true,
	        	MapTypeControlOptions: false,
	        	MapTypeControlStyle: false,
	        	OverviewMapControlOptions: false,
		        PanControlOptions: false,
		        RotateControlOptions: false,
		        ScaleControlOptions: false,
		        ScaleControlStyle: false,
		        StreetViewControlOptions: false,
		        ZoomControlOptions: false,
		        ZoomControlStyle: false,
		        ControlPosition: false,
		        draggable: false,
		        scrollwheel: false,
		        zoomControl: false,
		        keyboardShortcuts: false,
		        mapTypeId: google.maps.MapTypeId.ROADMAP
	 		};
	 		MAP = new google.maps.Map($("#googleMap")[0], mapOptions);
	 		var infoWindow = new google.maps.InfoWindow({
	 			content: address,
	 			size: new google.maps.Size(100, 50)
	 		});
	 		var marker = new google.maps.Marker({
	 			position: results[0].geometry.location,
	 			map: MAP,
	 			title: address
	 		});
	 		google.maps.event.addListener(marker, 'click', function(){
	 			infoWindow.open(MAP, marker);
	 		});
 		}
 	});
}

$(document).ready(function(){
	if($("#googleMap").length){
		initializeMap($("#mapAddr").text());
	}
})