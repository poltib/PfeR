var map, path = new google.maps.MVCArray(),
    service = new google.maps.DirectionsService(), 
    poly,
    allPath,
    SAMPLES = 200,
    elevationReqActive = false,
    mousemarker = null;

google.maps.event.addDomListener(window, 'load', loadFestivalMap);
google.load("visualization", "1", {packages: ["columnchart"]});


function loadFestivalMap() {
  jsLi = document.getElementById("jsRoute");
  jsInput = jsLi.childNodes[1];
  upLi = document.getElementById("upRoute");
  upLi.remove();

  var resetButton = document.createElement('div');
  var saveButton = document.createElement('div');
  var closeButton = document.createElement('div');
  var distButton = document.createElement('div');
  var fullButton = document.createElement('div');

  var saveContent = document.createTextNode("save");
  var beforeContent = document.createTextNode("reset");
  var closeContent = document.createTextNode("close");
  var distContent = document.createTextNode("dist");
  var fullContent = document.createTextNode("full");

  distButton.appendChild(distContent);
  fullButton.appendChild(fullContent);
  resetButton.appendChild(beforeContent);
  saveButton.appendChild(saveContent);
  closeButton.appendChild(closeContent);

  resetButton.setAttribute("class","reset");
  saveButton.setAttribute("class","save");
  closeButton.setAttribute("class","close");
  distButton.setAttribute("class","dist");
  fullButton.setAttribute("class","full");


  my_div = document.getElementById("happening-map");
  parentMy_div = my_div.parentNode;
  parentMy_div.insertBefore(resetButton, my_div);
  parentMy_div.insertBefore(saveButton, my_div);
  parentMy_div.insertBefore(closeButton, my_div);
  parentMy_div.insertBefore(distButton, my_div);
  parentMy_div.insertBefore(fullButton, my_div);

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
  poly = new google.maps.Polyline({ draggable: true, editable:true, geodesic:true, map: map, strokeColor: 'rgba(0,0,0,0.6)'});

  // Create a new chart in the elevation_chart DIV.
  chart = new google.visualization.ColumnChart(document.getElementById('elevation_chart'));
  // Create an ElevationService.
  elevationService = new google.maps.ElevationService();
  infowindow = new google.maps.InfoWindow({});
  // Create an ElevationService.
  elevationService = new google.maps.ElevationService();
  infowindow = new google.maps.InfoWindow({});
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

  google.maps.event.addListener(map, "click", function(evt) {
    if (path.getLength() === 0) {
      path.push(evt.latLng);
      poly.setPath(path);
    } else {
      service.route({
        origin: path.getAt(path.getLength() - 1),
        destination: evt.latLng,
        travelMode: google.maps.DirectionsTravelMode.WALKING
      }, function(result, status) {
        if (status == google.maps.DirectionsStatus.OK) {
          for (var i = 0, len = result.routes[0].overview_path.length;
              i < len; i++) {
            path.push(result.routes[0].overview_path[i]);
            drawPath(path.j);
            distButton.childNodes[0].nodeValue = poly.inKm();
            distButton.childNodes[0].nodeValue.replace(/^(\d{1,}.)(\d{2})/, '$1$2 km');
          }
        }
      });
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

  closeButton.addEventListener("click", function(evt) {
    if (path.getLength() === 0) {

    } else {
      service.route({
        origin: path.getAt(path.getLength() - 1),
        destination: path.getAt(0),
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
  },false);

  saveButton.addEventListener("click", function(evt) {
    if (path.getLength() === 0) {

    } else {
      jsInput.value = path.j.toString();
    }
  },false);

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
      elevations = results;

      // Extract the elevation samples from the returned results
      // and store them in an array of LatLngs.

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


}