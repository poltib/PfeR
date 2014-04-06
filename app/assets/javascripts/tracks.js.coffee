# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
if document.location.pathname == '/tracks/new' || document.location.pathname == '/happenings/'+document.getElementById('happening_id').innerText+'/tracks/new'
  gm_service = new google.maps.DirectionsService()
  path = new google.maps.MVCArray()
  poly = 1
  chart = 1
  elevations = 1
  SAMPLES = 200
  newRoute = []
  elevationReqActive = false
  elevationService = new google.maps.ElevationService()
  google.load("visualization", "1", {packages: ["columnchart"]})

gm_init = ->
  gm_center = new google.maps.LatLng(50.633333, 5.566667)
  gm_map_type = google.maps.MapTypeId.ROADMAP
  map_options = {zoom: 14, center: gm_center, panControl: false, backgroundColor: "rgba(0,0,0,0)", mapTypeControl: false, disableDoubleClickZoom: true, scrollwheel: false, draggableCursor: "crosshair"}
  new google.maps.Map(@map_canvas,map_options);

poly_init = (map) ->
  poly_options = { draggable: true, editable:true, geodesic:true, map: map, strokeColor: 'rgba(0,0,0,0.6)'}
  new google.maps.Polyline(poly_options)

growPath = (origin, destination) ->
  gm_service.route({
      origin: origin,
      destination: destination,
      travelMode: google.maps.DirectionsTravelMode.WALKING
    }, (result, status) ->
      if status == google.maps.DirectionsStatus.OK
        for i in result.routes[0].overview_path by 1
          path.push(i)
        drawPath(path.j)
        dist.childNodes[0].nodeValue = poly.inKm()
        undefined
  )

drawPath = (path) ->
  if elevationReqActive || !path
    return
  # Create a PathElevationRequest object using this array.
  # Ask for 100 samples along that path.
  pathRequest = {
    path: path,
    samples: SAMPLES
  }
  elevationReqActive = true
  # Initiate the path request.
  elevationService.getElevationAlongPath(pathRequest, plotElevation)

plotElevation = (results, status) ->
  elevationReqActive = false
  if status == google.maps.ElevationStatus.OK
    elevations = results
    # Extract the data from which to populate the chart.
    # Because the samples are equidistant, the 'Sample'
    # column here does double duty as distance along the
    # X axis.
    data = new google.visualization.DataTable()
    data.addColumn('string', 'Sample')
    data.addColumn('number', 'Elevation')
    for i in results by 1
      data.addRow(['', elevations[_i].elevation]);
    # Draw the chart using the data within its DIV.
    elevation_chart.style.display = 'block'
    chart.draw(data, { width: 'auto', height: 90, legend: 'none', titleY: 'Elevation (m)'})
    undefined


load_track = (id,map) ->
  callback = (data) -> display_on_map(data,map)
  $.get '/tracks/'+id+'.json', {}, callback, 'json'

display_on_map = (data,map) ->
  decoded_path = google.maps.geometry.encoding.decodePath(data.polyline)
  path_options = { path: decoded_path, strokeColor: "#FF0000",strokeOpacity: 0.5, strokeWeight: 5}
  track_path = new google.maps.Polyline(path_options)
  track_path.setMap(map)
  map.fitBounds(calc_bounds(track_path));

calc_bounds = (track_path) ->
  b = new google.maps.LatLngBounds()
  gm_path = track_path.getPath()
  path_length = gm_path.getLength()
  i = [0,(path_length/3).toFixed(0),(path_length/3).toFixed(0)*2]
  b.extend(gm_path.getAt(i[0]))
  b.extend(gm_path.getAt(i[1]))
  b.extend(gm_path.getAt(i[2]))


# When the page is loaded
$ ->
  dist = document.getElementById "dist"
  reset = document.getElementById "reset"
  close = document.getElementById "close"
  clear = document.getElementById "clear"
  save = document.getElementById "save"

  map = gm_init()

  if save?
    jsInput = document.getElementById("jsRoute").childNodes[0];
    elevation_chart = document.getElementById('elevation_chart')
    chart = new google.visualization.ColumnChart(elevation_chart);
    upLi = document.getElementById("upRoute");
    upLi.remove();
    poly = poly_init(map)
    google.maps.event.addListener map, 'click', (evt) ->
      if path.getLength() == 0
        path.push(evt.latLng)
        poly.setPath(path)
      else
        growPath(path.getAt(path.getLength() - 1), evt.latLng)

    reset.addEventListener 'click', (evt) ->
      path.clear();
      elevation_chart.style.display = 'none'
      dist.childNodes[0].nodeValue = 'dist'
      if mousemarker != null
        mousemarker.setMap(null)

    close.addEventListener 'click', (evt) ->
      if path.getLength() != 0
        growPath(path.getAt(path.getLength() - 1),path.getAt(0))

    save.addEventListener 'click', (evt) ->
      if path.getLength() != 0
        for i in elevations by 1
          newRoute[_i] = elevations[_i].location.A.toString().replace(/^(\d+.)(\d{0,5})(\d+)/, '$1$2') + ',' + elevations[_i].location.k.toString().replace(/^(\d+.)(\d{0,5})(\d+)/, '$1$2') + ',' + elevations[_i].elevation.toString().replace(/^(\d+)(.)(\d+)$/, '$1')
        jsInput.value = newRoute
        undefined

    google.maps.Polyline::inKm = (n) ->
      a = this.getPath(n)
      len = a.getLength()
      dist = 0
      for i in len-1 by 1
        dist += a.getAt(i).kmTo(a.getAt(_i+1))
      dist = dist.toString().replace(/^(\d+.)(\d{2})(\d+)$/, '$1$2 km')
      return dist

    google.maps.LatLng::kmTo = (a) ->
      e = Math ra = e.PI/180
      b = this.lat() * ra c = a.lat() * ra d = b - c
      g = this.lng() * ra - a.lng() * ra
      f = 2 * e.asin(e.sqrt(e.pow(e.sin(d/2), 2) + e.cos(b) * e.cos 
      (c) * e.pow(e.sin(g/2), 2)))
      return f * 6378.137
  else
    load_track(js_track_id,map)
