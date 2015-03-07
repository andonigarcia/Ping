var MAP;

function initializeMap(lat, lng){
	var CENTER = new google.maps.LatLng(lat, lng);
	var mapOptions = {
		center: CENTER,
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
	var marker = new google.maps.Marker({
		position: CENTER,
		map: MAP,
		title: 'My Company'
	});
}

$(document).ready(function(){
	if($("#googleMap").length){
		arr = $("#mapAddr").text().trim().split(" ");
		initializeMap(parseFloat(arr[0]), parseFloat(arr[1]));
	}
})