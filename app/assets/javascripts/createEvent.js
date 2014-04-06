var map, path = new google.maps.MVCArray(),
    service = new google.maps.DirectionsService(), 
    poly,
    allPath,
    SAMPLES = 200,
    elevationReqActive = false,
    mousemarker = null;
var trajet = [];
var newRoute = [];
var fileExt;
google.load("visualization", "1", {packages: ["columnchart"]});
google.maps.event.addDomListener(window, 'load', loadMap);


function loadMap() {

  var resetButton = document.getElementsByClassName('reset')[0];
  var saveButton = document.getElementsByClassName('save')[0];
  var closeButton = document.getElementsByClassName('close')[0];
  var distButton = document.getElementsByClassName('dist')[0];
  var fullButton = document.getElementsByClassName('full')[0];

  var myOptions = {
    zoom: 14,
    center: new google.maps.LatLng(50.633333, 5.566667),
    panControl: false,
    backgroundColor: "rgba(0,0,0,0)",
    mapTypeControl: false,
    disableDoubleClickZoom: true,
    scrollwheel: false,
    draggableCursor: "crosshair"
  }

  map = new google.maps.Map(document.getElementById("happening-map"), myOptions);
  // Create a new chart in the elevation_chart DIV.
  chart = new google.visualization.ColumnChart(document.getElementById('elevation_chart'));
  // Create an ElevationService.
  elevationService = new google.maps.ElevationService();
  infowindow = new google.maps.InfoWindow({});

  if (saveButton) {
    // Create event
    jsInput = document.getElementById("jsRoute").childNodes[1];
    upLi = document.getElementById("upRoute");
    upLi.remove();
    poly = new google.maps.Polyline({ draggable: true, editable:true, geodesic:true, map: map, strokeColor: 'rgba(0,0,0,0.6)'});
    google.maps.event.addListener(map, "click", function(evt) {
      if (path.getLength() === 0) {
        path.push(evt.latLng);
        poly.setPath(path);
      } else {
        growPath(path.getAt(path.getLength() - 1), evt.latLng)
      }
    });

    resetButton.addEventListener("click", function(evt) {
      path.clear();
      document.getElementById('elevation_chart').style.display = 'none';
      distButton.childNodes[0].nodeValue = 'dist';
      if (mousemarker != null) {
        mousemarker.setMap(null);
      }
    });

    fullButton.addEventListener("click", function(evt) {
      map.styles.height = '100%'
      map.styles.width = '100%'
    });

    closeButton.addEventListener("click", function(evt) {
      if (path.getLength() !== 0) {
        growPath(path.getAt(path.getLength() - 1),path.getAt(0));
      }
    },false);

    saveButton.addEventListener("click", function(evt) {
      if (path.getLength() !== 0) {
        for (var i = elevations.length - 1; i >= 0; i--) {
          newRoute[i] = elevations[i].location.A + ',' + elevations[i].location.k + ',' + elevations[i].elevation;
        };
        console.log(newRoute);
        jsInput.value = newRoute;
      }
    },false);

  } else{
  // Show event
    fileExt = document.getElementsByClassName('fileExt')[0].firstChild.textContent;

    if(fileExt === ".gpx"){
      var lats = document.getElementsByClassName('lat');
      var lons = document.getElementsByClassName('lon'); 
    }

    if(fileExt === ".tcx"){
      var lats = document.getElementsByClassName('LatitudeDegrees');
      var lons = document.getElementsByClassName('LongitudeDegrees'); 
    }

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
    
  };

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

  function growPath(origin, destination) {
    service.route({
      origin: origin,
      destination: destination,
      travelMode: google.maps.DirectionsTravelMode.WALKING
    }, function(result, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        for (var i = 0, len = result.routes[0].overview_path.length;
            i < len; i++) {
          path.push(result.routes[0].overview_path[i]);
          drawPath(path.j);
          distButton.childNodes[0].nodeValue = poly.inKm();

        }
      }
    });
  }

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

  function plotElevation(results, status) {
    elevationReqActive = false;
    if (status == google.maps.ElevationStatus.OK) {
      // Extract the elevation samples from the returned results
      // and store them in an array of LatLngs.
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
        poly = new google.maps.Polyline(pathOptions);
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
        width: 'auto',
        height: 90,
        legend: 'none',
        titleY: 'Elevation (m)'
      });
    }
  }


  google.maps.LatLng.prototype.kmTo = function(a){ 
    var e = Math, ra = e.PI/180; 
    var b = this.lat() * ra, c = a.lat() * ra, d = b - c; 
    var g = this.lng() * ra - a.lng() * ra; 
    var f = 2 * e.asin(e.sqrt(e.pow(e.sin(d/2), 2) + e.cos(b) * e.cos 
    (c) * e.pow(e.sin(g/2), 2))); 
    return f * 6378.137; 
  } 

  google.maps.Polyline.prototype.inKm = function(n){ 
    var a = this.getPath(n), len = a.getLength(), dist = 0; 
    for(var i=0; i<len-1; i++){ 
      dist += a.getAt(i).kmTo(a.getAt(i+1)); 
    }
    dist = dist.toString().replace(/^(\d{1,}.)(\d{2})(\d{1,})$/, '$1$2 km');
    return dist; 
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
  }
}