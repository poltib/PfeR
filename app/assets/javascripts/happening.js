

google.load('visualization', '1.0', {'packages':['columnchart']});

//Create the variable for the main map itself.
var mapZoom = 13;
var mapZoomMax = 18;
var mapZoomMin = 4;
var map;
var elevator;
var chart;
var infowindow = new google.maps.InfoWindow();
var polyline;
var trajet = [];
var gMarker;
var startPosition;
var sponsorsPosition = [];
var gGeocoder;
var fileExt;
var path;
var SAMPLES = 200;
var elevationReqActive = false;
var mapCenter;
var mousemarker = null;

//When the page loads, the line below calls the function below called 'loadmap' to load up the map.
google.maps.event.addDomListener(window, 'load', loadMap);


//THE MAIN FUNCTION THAT IS CALLED WHEN THE WEB PAGE LOADS--------------------------------------------------------------------------------
function loadMap() {

  fileExt = document.getElementsByClassName('fileExt')[0].firstChild.textContent;

  if(fileExt === ".gpx"){
    var lats = document.getElementsByClassName('lat');
    var lons = document.getElementsByClassName('lon'); 
  }

  if(fileExt === ".tcx"){
    var lats = document.getElementsByClassName('LatitudeDegrees');
    var lons = document.getElementsByClassName('LongitudeDegrees'); 
  }

startPosition = document.getElementsByClassName('address')[0].firstChild.textContent;

// getLatLong(startPosition);
// var sponsorsAdress = document.getElementsByClassName('sponsorAddress');

// for(var i=0; i < sponsorsAdress.length; ++i){
//      sponsorsPosition[i] = [sponsorsAdress[i].firstChild.textContent, 'sponsor'+i];
// }
function getLatLong(address) {
  var geocoder = new google.maps.Geocoder();
  var result = "";
  geocoder.geocode( { 'address': startPosition, 'region': 'be' }, function(results, status) {
     if (status == google.maps.GeocoderStatus.OK) {
         result[0] = results[0].geometry.location.lat();
         result[1] = results[0].geometry.location.lng();
     } else {
         result = "Unable to find address: " + status;
     }
     storeResult(result);
    });
}

function storeResult(result){
  mapCenter = new google.maps.LatLng(result['lat'], result['lng']);
}


mapCenter = new google.maps.LatLng(50.6133103216808067, 5.4413223266601562);


var mapOptions = { 
      center:mapCenter, 
      zoom: mapZoom,
      maxZoom:mapZoomMax,
      scrollwheel:false,
      minZoom:mapZoomMin,
      panControl: false,
      mapTypeControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
};

  
//The variable to hold the map was created above.The line below creates the map, assigning it to this variable. The line below also loads the map into the div with the id 'festival-map' (see code within the 'body' tags below), and applies the 'mapOptions' (above) to configure this map. 
map = new google.maps.Map(document.getElementById("happening-map"), mapOptions); 

chart = new google.visualization.ColumnChart(document.getElementById('elevation_chart'));

google.visualization.events.addListener(chart, 'onmouseover', function(e) {
  if (mousemarker == null) {
    mousemarker = new google.maps.Marker({
    position: elevations[e.row].location,
    map: map,
    icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
    });
    var contentStr = "elevation="+elevations[e.row].elevation+"<br>location="+elevations[e.row].location.toUrlValue(6);
    mousemarker.contentStr = contentStr;
    google.maps.event.addListener(mousemarker, 'click', function(evt) {
    mm_infowindow_open = true;
    infowindow.setContent(this.contentStr);
    infowindow.open(map,mousemarker);
    });
  } else {
    var contentStr = "elevation="+elevations[e.row].elevation+"<br>location="+elevations[e.row].location.toUrlValue(6);
    mousemarker.contentStr = contentStr;
    infowindow.setContent(contentStr);
    mousemarker.setPosition(elevations[e.row].location);
  }
});


gMarker = new google.maps.Marker( {
      position:mapCenter,
      map:map
    } );

// Create an ElevationService.
elevationService = new google.maps.ElevationService();

if(fileExt === ".tcx" | fileExt === ".gpx"){
  for(var i=0; i < lats.length; ++i){
    trajet[i] = new google.maps.LatLng(lats[i].firstChild.textContent, lons[i].firstChild.textContent);
  }
  // Draw the path, using the Visualization API and the Elevation service.
  drawPath(trajet);
}else{
  var file = document.getElementsByClassName('filePath')[0].firstChild.textContent;
  parser = new geoXML3.parser({
    map: map,
    processStyles: true,
    zoom: true,
    afterParse: useTheData
    }
  );

  parser.parse([file]);
}

// var setMarker = function( sAddress , gMarker ){
//     gGeocoder.geocode({
//       address: sAddress,
//       region:"BE"
//     }, function(aResults, sStatus){
//       gMarker.setPosition( aResults[0].geometry.location );
//     });
//   };

// setMarker(startPosition, gMarker);

// for(var i=0; i < sponsorsPosition.length; ++i){
//      sponsorsPosition[i][1] = new google.maps.Marker( {
//         position:mapCenter,
//         map:map
//       } );

//      setMarker(sponsorsPosition[i][0], sponsorsPosition[i][1]);
// }
function drawPath(path) {
    if (elevationReqActive || !path) return;


    // Create a PathElevationRequest object using this array.
    // Ask for 100 samples along that path.
    var pathRequest = {
      path: path,
      samples: SAMPLES
    }
    elevationReqActive = true;

    // Initiate the path request.
    elevationService.getElevationAlongPath(pathRequest, plotElevation);
  }


// Takes an array of ElevationResult objects, draws the path on the map
// and plots the elevation profile on a Visualization API ColumnChart.
function plotElevation(results, status) {
  if (status != google.maps.ElevationStatus.OK) {
    return;
  }
  elevations = results;

  if(fileExt === ".tcx" | fileExt === ".gpx"){
    // Extract the elevation samples from the returned results
    // and store them in an array of LatLngs.
    var elevationPath = [];
    for (var i = 0; i < results.length; i++) {
      elevationPath.push(elevations[i].location);
    }
    // Display a polyline of the elevation path.
    var pathOptions = {
      path: elevationPath,
      strokeColor: 'rgb(244,129,64)',
      opacity: 0.4,
      map: map
    }
    polyline = new google.maps.Polyline(pathOptions);
  }

  // Extract the data from which to populate the chart.
  // Because the samples are equidistant, the 'Sample'
  // column here does double duty as distance along the
  // X axis.
  var data = new google.visualization.DataTable();
  data.addColumn('string', 'Sample');
  data.addColumn('number', 'Elevation');
  for (var i = 0; i < results.length; i++) {
    data.addRow(['', elevations[i].elevation]);
  }

  // Draw the chart using the data within its DIV.
  document.getElementById('elevation_chart').style.display = 'block';
  chart.draw(data, {
    chartType: 'LineChart',
    width: 'auto',
    height: 150,
    colors: ['#90A1BF'],
    width: 'auto',
    legend: 'none',
    titleY: 'Elevation (m)',
    titleX: 'Distance'
  });
}

//
// Triggered by our parsecomplete event
//
function useTheData(doc){
  geoXmlDoc = doc[0];
  for (var i = 0; i < geoXmlDoc.placemarks.length; i++) {
    // console.log(doc[0].markers[i].title);
    var placemark = geoXmlDoc.placemarks[i];
    placemark.polyline.strokeColor = 'rgb(244,129,64)';
    placemark.polyline.strokeWeight = 3;
    if (placemark.polyline) {
      if (!path) {
        path = [];
        var samples = placemark.polyline.getPath().getLength();
        var incr = samples/SAMPLES;
        if (incr < 1) incr = 1;
        for (var i=0;i<samples; i+=incr)
        {
          path.push(placemark.polyline.getPath().getAt(parseInt(i)));
        }
      }                
    }
  }
  drawPath(path);
};
}