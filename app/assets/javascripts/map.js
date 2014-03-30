//
// Globals
//
var mapInstance;
var parser;
var path;
var file;
var SAMPLES = 200;
var elevationReqActive = false;
var mousemarker = null;
// Load the Visualization API and the piechart package.
google.load("visualization", "1", {packages: ["columnchart"]});

$(document).ready(function() {
	var latlng = new google.maps.LatLng(35.603789, -77.364693);
	var mapOptions = {
		zoom: 16,
		center: latlng,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		mapTypeControlOptions: {
		style: google.maps.MapTypeControlStyle.DEFAULT
		}
	};
	mapInstance = new google.maps.Map(document.getElementById("happening-map"), mapOptions);

	// Create a new chart in the elevation_chart DIV.
	chart = new google.visualization.ColumnChart(document.getElementById('elevation_chart'));
	// Create an ElevationService.
	elevationService = new google.maps.ElevationService();
	infowindow = new google.maps.InfoWindow({});
	google.visualization.events.addListener(chart, 'onmouseover', function(e) {
	if (mousemarker == null) {
		mousemarker = new google.maps.Marker({
		position: elevations[e.row].location,
		map: mapInstance,
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

	// Create a new parser for all the KML
	// processStyles: true means we want the styling defined in KML to be what isrendered
	// singleInfoWindow: true means we only want 1 simultaneous info window open
	// zoom: false means we don't want torecenter/rezoom based on KML data
	// afterParse: customAfterparse is a method to add the sidebar once parsing is done
	//
	var file = document.getElementsByClassName('filePath')[0].firstChild.textContent;
	parser = new geoXML3.parser({
		map: mapInstance,
		processStyles: true,
		zoom: true,
		afterParse: useTheData
		}
	);

	parser.parse([file]);

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
        height: 150,
        legend: 'none',
        titleY: 'Elevation (m)'
      });
    }
  }

  //
// Triggered by our parsecomplete event
//
function useTheData(doc){
  geoXmlDoc = doc[0];
  for (var i = 0; i < geoXmlDoc.placemarks.length; i++) {
    // console.log(doc[0].markers[i].title);
    var placemark = geoXmlDoc.placemarks[i];
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

});
