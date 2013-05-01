var MapUtils = {};

MapUtils.ActualMap = null;
MapUtils.LocationPoints = null;
MapUtils.InfoWindow = null;
MapUtils.MarkersArray = [];
MapUtils.MarkersEventListenerArray = [];
MapUtils.Points = [];
// MapUtils.Position.lat == null => Acceso negado con Not Now
// se usa setTimeout porque Not Now no invoca funcion de error
// MapUtils.Position.lat == error => Acceso negado con Never
// Invoca funcion de error, así evita setTimeout
MapUtils.Position = { lat: null, lng: null };

MapUtils.configMap = function(mapId) {

	MapUtils.LocationPoints = $('#col_left').detach();
	$('#col_right').removeClass('span10')
	$('#col_right').addClass('span12');
	$('#buttonOcultar').hide();
	var mapOptions = {
  		center: new google.maps.LatLng(MapUtils.Position.lat, MapUtils.Position.lng),
    	zoom: 13,
    	mapTypeId: google.maps.MapTypeId.ROADMAP
  	};
  
  	MapUtils.ActualMap = new google.maps.Map(document.getElementById(mapId), mapOptions);
	MapUtils.InfoWindow = new google.maps.InfoWindow();
	MapUtils.ustedEstaAqui({latitude: MapUtils.Position.lat, longitude: MapUtils.Position.lng});

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
		MapUtils.getNearLocationPoints(MapUtils.Position.lat, MapUtils.Position.lng);
	});

	$('#buttonOcultar').click(function() {
		MapUtils.LocationPoints = $('#col_left').detach();
		$('#col_right').removeClass('span10')
		$('#col_right').addClass('span12');
		MapUtils.cleanMarkers();
		$('#buttonOcultar').hide();
	});
};

MapUtils.getNearLocationPoints = function(currentLat, currentLng) {
	$.getJSON('/location_points/near_location_points', { lat: currentLat, lng: currentLng }, function(points) {
		MapUtils.Points = points;
		$('#map_filters_result').empty();
		$.tmpl('temp_location_point_item', points).appendTo('#map_filters_result');
		MapUtils.setNearLocationPointsMarkers();
	});
};

MapUtils.cleanMarkers = function(){

	if(MapUtils.MarkersEventListenerArray.length !== 0){
		for(var i = 0; i < MapUtils.MarkersEventListenerArray.length; i++){
			google.maps.event.removeListener(MapUtils.MarkersEventListenerArray[i]);
		}
	}
	MapUtils.MarkersEventListenerArray = [];

	if(MapUtils.MarkersArray.length !== 0){
		for(var i = 0; i < MapUtils.MarkersArray.length; i++){
			MapUtils.MarkersArray[i].marker.setMap(null);
		}
	}
	MapUtils.MarkersArray = [];
};

MapUtils.setNearLocationPointsMarkers = function() {
	MapUtils.cleanMarkers();
	if(MapUtils.Points.length !== 0){
		for(var i = 0; i < MapUtils.Points.length; i++){
			MapUtils.setSingleMarker(MapUtils.Points[i], 0, true);
		}
	}
};

MapUtils.findPointMarkerById = function(id) {
	var MarkerAndPos;
	if(MapUtils.Points.length !== 0){
		for(var i = 0; i < MapUtils.Points.length; i++){
			if (MapUtils.Points[i].id==id){
				MarkerAndPos = { m: MapUtils.Points[i], p: i };
				return MarkerAndPos;
			}
		}
	}
	return null;
};

MapUtils.setSingleMarker = function(MData, M_id, add) {
	var latLng, marker, dataListener, MapsEventListener;
	if(add){
		MarkerData = MData;
		latLng = new google.maps.LatLng(MarkerData.latitude, MarkerData.longitude);
		marker = new google.maps.Marker({
   			position: latLng,
   			map: MapUtils.ActualMap,
   			title: 'Dev tipo: ' + MarkerData.device_id
		});
		dataListener = 'id: ' + MarkerData.id + '<br>device_id: ' + MarkerData.device_id + '<br>latitud: ' 
			+ MarkerData.latitude + '<br>longitud: ' + MarkerData.longitude + '<br>Diferente solo para ver que se puede';
		MapsEventListener = google.maps.event.addListener(marker, 'click', (function(marker, dataListener) {
			return function() {
				MapUtils.InfoWindow.setContent(dataListener);
				MapUtils.InfoWindow.open(MapUtils.ActualMap, marker);
			}
		})(marker, dataListener));
		MapUtils.MarkersArray.push({ marker: marker, latLng: latLng, dataListener: dataListener });
		MapUtils.MarkersEventListenerArray.push(MapsEventListener);
	} else {
		if (MarkerData!=null) {
			MarkerData = MapUtils.findPointMarkerById(M_id);
			$('#tmplVarInfoWindow').empty();
			$.tmpl('temp_InfoWindow', MarkerData.m).appendTo('#tmplVarInfoWindow');
			dataListener = $("#tmplVarInfoWindow").html();
			MapUtils.ActualMap.setCenter(MapUtils.MarkersArray[MarkerData.p].latLng);
//		MapUtils.InfoWindow.setContent(MapUtils.MarkersArray[MarkerData.p].dataListener);
//		los dataListener son diferentes para experimentar, despues vemos cual dejamos
			MapUtils.InfoWindow.setContent(dataListener);
			MapUtils.InfoWindow.open(MapUtils.ActualMap, MapUtils.MarkersArray[MarkerData.p].marker);
		}
	}
};

MapUtils.ustedEstaAqui = function(MarkerData) {
	var latLng, marker, dataListener, MapsEventListener;
	latLng = new google.maps.LatLng(MarkerData.latitude, MarkerData.longitude);
	marker = new google.maps.Marker({
   		position: latLng,
   		map: MapUtils.ActualMap,
   		title: 'Usted esta aqui',
   		icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=*|0066FF|FFFFFF'
	});
	dataListener = '<b>Usted est&aacute; aqu&iacute</b>' + '<br>latitud: ' + MarkerData.latitude + '<br>longitud: ' + MarkerData.longitude;
	MapsEventListener = google.maps.event.addListener(marker, 'click', (function(marker, dataListener) {
		return function() {
			MapUtils.InfoWindow.setContent(dataListener);
			MapUtils.InfoWindow.open(MapUtils.ActualMap, marker);
		}
	})(marker, dataListener));
};

MapUtils.getLocation = function() {
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(MapUtils.setPosition, MapUtils.showError, {timeout: 5000, enableHighAccuracy: true, maximumAge: 3000});
	}
	setTimeout(function(){
			if (MapUtils.Position.lat==null){
				$("#general_map").html('<h3>' + 'Se a negado temporalmente el acceso a geolocalización.' + '</h3>');
			}
		},5500);
};

MapUtils.setPosition = function(position) {
	MapUtils.Position.lat = position.coords.latitude;
	MapUtils.Position.lng = position.coords.longitude;
	MapUtils.configMap('general_map');
};

MapUtils.showError = function(error) {
	var message;
	switch(error.code) {
		case error.PERMISSION_DENIED:
			message='Se a negado el acceso a geolocalización.';
			break;
		case error.POSITION_UNAVAILABLE:
			message='Geolocalización no disponible.';
			break;
	case error.TIMEOUT:
			message='Geolocalización no disponible en el tiempo requerido.';
			break;
	case error.UNKNOWN_ERROR:
			message='Se ha producido un error de geolocalización.';
			break;
	}
	MapUtils.Position.lat='error';
	$("#general_map").html('<h3>' + message + '</h3>');
};
