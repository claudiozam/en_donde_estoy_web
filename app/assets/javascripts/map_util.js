var MapUtils = {};

MapUtils.ActualMap = null;
MapUtils.LocationPoints = null;
MapUtils.InfoWindow = null;
MapUtils.MarkersArray = [];
MapUtils.MarkersEventListenerArray = [];

MapUtils.configMap = function(mapId) {

	MapUtils.LocationPoints = $('#col_left').detach();
	$('#col_right').removeClass('span10')
	$('#col_right').addClass('span12');
	$('#buttonOcultar').hide();

	var mapOptions = {
  		center: new google.maps.LatLng(-34.59707,-58.416501),
    	zoom: 13,
    	mapTypeId: google.maps.MapTypeId.ROADMAP
  	};
  
  	MapUtils.ActualMap = new google.maps.Map(document.getElementById(mapId), mapOptions);
	MapUtils.InfoWindow = new google.maps.InfoWindow();

	$(window).resize(function () {
	    var h = $(window).height();
	    var offsetTop = $('.navbar').height() + $('#map_filters').height() + 60; // Calculate the top offset
	    $('#' + mapId).css('height', (h - offsetTop));
	}).resize();

	$('#buttonBuscar').click(function() {
		$('#buttonOcultar').show();
		$('#col_right').removeClass('span12')
		$('#col_right').addClass('span10');
		$(MapUtils.LocationPoints).insertBefore('#col_right');
		//MapUtils.getNearLocationPoints(-34.595381, -58.423716);
		MapUtils.setNearLocationPointsMarkers(-34.595381, -58.423716);
	});

	$('#buttonOcultar').click(function() {
		MapUtils.LocationPoints = $('#col_left').detach();
		$('#col_right').removeClass('span10')
		$('#col_right').addClass('span12');
/**/
		if(MapUtils.MarkersEventListenerArray.length !== 0){
			for(var i = 0; i < MapUtils.MarkersEventListenerArray.length; i++){
				google.maps.event.removeListener(MapUtils.MarkersEventListenerArray[i]);
			}
		}
		MapUtils.MarkersEventListenerArray = [];
/**/

		if(MapUtils.MarkersArray.length !== 0){
			for(var i = 0; i < MapUtils.MarkersArray.length; i++){
				MapUtils.MarkersArray[i].setMap(null);
			}
		}
		MapUtils.MarkersArray = [];

		$('#buttonOcultar').hide();
	});
};

/*MapUtils.getNearLocationPoints = function(currentLat, currentLng) {
	$.getJSON('/location_points/near_location_points', { lat: currentLat, lng: currentLng }, function(points) {
		$('#map_filters_result').empty();
		$.tmpl('templates/location_point_item', points).appendTo('#map_filters_result');
	});
};*/


MapUtils.setNearLocationPointsMarkers = function(currentLat, currentLng) {
	var latLng, marker, dataListener, MapsEventListener;
	$.getJSON('/location_points/near_location_points', { lat: currentLat, lng: currentLng }, function(points) {
		
		$('#map_filters_result').empty();
		$.tmpl('templates/location_point_item', points).appendTo('#map_filters_result');

		$.each(points, function(i, field){
			latLng = new google.maps.LatLng(field.latitude, field.longitude);
			marker = new google.maps.Marker({
				position: latLng,
				map: MapUtils.ActualMap,
				title: 'Dev tipo: ' + field.device_id
			});
			dataListener = 'id: ' + field.id + '<br>device_id: ' + field.device_id + '<br>latitud: ' + field.latitude + '<br>longitud: ' + field.longitude;
			MapsEventListener = google.maps.event.addListener(marker, 'click', (function(marker, dataListener) {
				return function() {
					MapUtils.InfoWindow.setContent(dataListener);
					MapUtils.InfoWindow.open(MapUtils.ActualMap, marker);
				}
			})(marker, dataListener));
			MapUtils.MarkersArray.push(marker);
			MapUtils.MarkersEventListenerArray.push(MapsEventListener);
		});
	});
};
