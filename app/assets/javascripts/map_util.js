var MapUtils = {};

MapUtils.ActualMap = null;

MapUtils.configMap = function(mapId) {

	var mapOptions = {
  		center: new google.maps.LatLng(-34.59707,-58.416501),
    	zoom: 13,
    	mapTypeId: google.maps.MapTypeId.ROADMAP
  	};
  
  	MapUtils.ActualMap = new google.maps.Map(document.getElementById(mapId), mapOptions);

	$(window).resize(function () {
	    var h = $(window).height();
	    var offsetTop = $('.navbar').height() + $('#map_filters').height() + 60; // Calculate the top offset
	    $('#' + mapId).css('height', (h - offsetTop));
	}).resize();


	$('#linkBuscar').click(function() {
		
		var marker = new google.maps.Marker({
            position: new google.maps.LatLng(-34.59707,-58.416501),
            map: MapUtils.ActualMap,
            title: 'Hello World!'
        });
		MapUtils.getNearLocationPoints(-34.595381, -58.423716);
	});

};

MapUtils.getNearLocationPoints = function(currentLat, currentLng) {
	$.getJSON('/location_points/near_location_points', { lat: currentLat, lng: currentLng }, function(points) {
		$('#map_filters_result').empty();
		$.tmpl('templates/location_point_item', points).appendTo('#map_filters_result');
	});
};
