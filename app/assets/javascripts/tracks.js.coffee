NUMBER_DOT_TWONUMBERS = /^(\d+.)(\d{0,2})(\d+)/
COORD = /^(\d+.)(\d{0,13})(\d+)/
poly = 1
chart = 1
elevations = 1
SAMPLES = 100
mousemarker = null
track_path = null
newRoute = []
elevationReqActive = false
alert = document.getElementById("alert")
notice = document.getElementById("notice")

if !alert.innerText
  alert.remove();

if !notice.innerText
  notice.remove();

if google?
  path = new google.maps.MVCArray()
  gm_service = new google.maps.DirectionsService()
  elevationService = new google.maps.ElevationService()
  google.load("visualization", "1", {packages: ["corechart"]})

gm_init = (gm_center) ->
  gm_map_type = google.maps.MapTypeId.ROADMAP
  map_options = {zoom: 14, center: gm_center, panControl: false, backgroundColor: "rgba(0,0,0,0)", mapTypeControl: false, disableDoubleClickZoom: true, scrollwheel: false, draggableCursor: "crosshair"}
  new google.maps.Map(@map_canvas,map_options);

poly_init = (map) ->
  poly_options = { 
    draggable: true, 
    editable:true, 
    geodesic:true, 
    map: map, 
    strokeColor: 'rgba(0,0,0,0.6)'
  }
  new google.maps.Polyline(poly_options)

drawPath = (path) ->
  return if elevationReqActive || !path
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
  return if status != google.maps.ElevationStatus.OK
  elevations = results
  # Extract the data from which to populate the chart.
  # Because the samples are equidistant, the 'Sample'
  # column here does double duty as distance along the
  # X axis.
  data = new google.visualization.DataTable()
  data.addColumn('string', 'Distance')
  data.addColumn('number', 'Elevation')
  dist = 0
  for i in elevations by 1
    data.addRow(['',elevations[_i].elevation])

  # Draw the chart using the data within its DIV.
  elevation_chart.style.display = 'block'
  options = {
    width: '100%',
    height: 150,
    bar: {groupWidth: "95%"},
    legend: { position: "none" },
    titleY: 'Elevation (m)',
    vAxis: {minValue: 0},
    colors: ["#C9CFF5"],
    focusBorderColor: '#00AA00',
    tooltip: { trigger: 'none' },
    bar: { groupWidth: '100%' }
  }
  chart.draw(data, options)
  undefined

load_track = (id,map) ->
  callback = (data) -> display_on_map(data,map)
  $.get '/tracks/'+id+'.json', {}, callback, 'json'

display_on_map = (data,map) ->
  decoded_path = google.maps.geometry.encoding.decodePath(data.polyline)
  # icon_set = { path: google.maps.SymbolPath.FORWARD_OPEN_ARROW }
  path_options = { path: decoded_path, strokeColor: "black",strokeOpacity: 0.8,map: map, strokeWeight: 5}
  track_path = new google.maps.Polyline(path_options)
  drawPath(decoded_path)
  map.fitBounds(calc_bounds(track_path));

calc_bounds = (track_path) ->
  b = new google.maps.LatLngBounds()
  gm_path = track_path.getPath()
  path_length = gm_path.getLength()
  i = [0,(path_length/3).toFixed(0),(path_length/3).toFixed(0)*2]
  b.extend(gm_path.getAt(i[0]))
  b.extend(gm_path.getAt(i[1]))
  b.extend(gm_path.getAt(i[2]))

set_markers_zoom = (map, markers, center) ->
  boundbox = new google.maps.LatLngBounds()
  boundbox.extend(new google.maps.LatLng(center.position.lat(), center.position.lng()))
  for marker in markers
    boundbox.extend(new google.maps.LatLng(marker.position.lat(), marker.position.lng()))
  map.setCenter(center.position)
  map.fitBounds(boundbox)

if google?
  google.maps.LatLng::kmTo = (a) ->
    e = Math 
    ra = e.PI/180
    b = this.lat() * ra
    c = a.lat() * ra
    d = b - c
    g = this.lng() * ra - a.lng() * ra
    f = 2 * e.asin(e.sqrt(e.pow(e.sin(d/2), 2) + e.cos(b) * e.cos(c) * e.pow(e.sin(g/2), 2)))
    return f * 6378.137

  google.maps.Polyline::inKm = (n) ->
    a = this.getPath(n)
    len = a.getLength()-1
    pathLenght = 0
    for i in [0...len] by 1
      pathLenght += a.getAt(i).kmTo(a.getAt(i+1))
    pathLenght.toString().replace(NUMBER_DOT_TWONUMBERS, '$1$2')

add_chart_listener = (map) ->
  infowindow = new google.maps.InfoWindow({})
  google.visualization.events.addListener chart, 'onmouseover', (e) ->
    if mousemarker == null
      mousemarker = new google.maps.Marker({
        position: elevations[e.row].location,
        map: map,
        icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
      })
      contentStr = "elevation="+elevations[e.row].elevation+"m"
      mousemarker.contentStr = contentStr
      google.maps.event.addListener mousemarker, 'click', (evt) ->
        mm_infowindow_open = true
        infowindow.setContent(this.contentStr)
        infowindow.open(map,mousemarker)
    else
      mousemarker.setMap(map)
      contentStr = "elevation="+elevations[e.row].elevation+"m"
      mousemarker.contentStr = contentStr
      infowindow.setContent(contentStr)
      mousemarker.setPosition(elevations[e.row].location)

$(".tracks.new, .happeningtracks.new").ready ->
  dist = document.getElementById "dist"
  reset = document.getElementById "reset"
  close = document.getElementById "close"
  clear = document.getElementById "clear"
  full = document.getElementById "full"
  divMap = document.getElementById "map_canvas"
  jsInput = document.getElementById("jsRoute").childNodes[0];
  distanceInput = document.getElementById("track_length");
  longitudeInput = document.getElementById("track_longitude");
  latitudeInput = document.getElementById("track_latitude");
  mapErrors = document.getElementById("mapErrors");
  elevation_chart = document.getElementById('elevation_chart')
  upLi = document.getElementById("upRoute");
  chart = new google.visualization.ColumnChart(elevation_chart);
  gm_center = new google.maps.LatLng(js_location[0], js_location[1])
  
  map = gm_init(gm_center)
  upLi.remove();
  poly = poly_init(map)
  add_chart_listener(map)

  $('.createForm').submit ->
    if !!jsInput.value
      true
    else
      mapErrors.style.display = 'block'
      mapErrors.childNodes[1].innerText = 'Vous devez créer un tracé'
      false

  google.maps.event.addListener map, 'click', (evt) ->
    if path.getLength() == 0
      path.push(evt.latLng)
      poly.setPath(path)
      latitudeInput.value = path.j[0].lat()
      longitudeInput.value = path.j[0].lng()
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

  full.addEventListener 'click', (evt) ->
    divMap.style.width = '100%'
    divMap.style.z-index = '100000'

  growPath = (origin, destination) ->
    gm_service.route({
        origin: origin,
        destination: destination,
        travelMode: google.maps.DirectionsTravelMode.WALKING
      }, (result, status) ->
        return if status != google.maps.DirectionsStatus.OK
        for i in result.routes[0].overview_path by 1
          path.push(i)
        drawPath(path.j)
        dist.childNodes[0].textContent = poly.inKm() + 'km'
        newRoute = ''
        for coords in path.j by 1
          if _j == 0
            newRoute += coords.k.toString() + ',' + coords.A.toString()
          else
            newRoute += ',' + coords.k.toString() + ',' + coords.A.toString()

        jsInput.value = newRoute
        distanceInput.value = poly.inKm()
        undefined
    )

$(".tracks.show").ready ->
  $( '#many a.thumbnail' ).heplbox()
  image_form = document.getElementById("addImage")
  show_form_button = document.getElementById("showImageForm")
  if image_form? 
    image_form.style.display = "none"

  if show_form_button
    show_form_button.addEventListener 'click', (evt) ->
      if image_form.style.display == "block"
        image_form.style.display = "none"
      else
        image_form.style.display = "block"
  if google?
    chart = new google.visualization.ColumnChart(elevation_chart)
    map = gm_init()
    load_track(js_track_id,map)
    add_chart_listener(map)

$(".tracks.index, .happenings.show").ready ->
  $( '#many a.thumbnail' ).heplbox()
  image_form = document.getElementById("addImage")
  show_form_button = document.getElementById("showImageForm")
  tracks_markers = []
  marker_center = null
  gm_center = new google.maps.LatLng(js_location[0], js_location[1])

  if image_form? 
    image_form.style.display = "none"

  if show_form_button
    show_form_button.addEventListener 'click', (evt) ->
      if image_form.style.display == "block"
        image_form.style.display = "none"
      else
        image_form.style.display = "block"

  elevation_chart = document.getElementById('elevation_chart')
  # console.log(js_location)
  load_track_on_click = (evt) ->
    for track in js_tracks by 1
      # replace take the 13 decimals of a coord because creating a marker with coords change them
      if track[0].toString().replace(COORD, '$1$2') == evt.latLng.lat().toString().replace(COORD, '$1$2') && track[1].toString().replace(COORD, '$1$2') == evt.latLng.lng().toString().replace(COORD, '$1$2')
        callback = (data) -> display_on_map(data,map)
        $.get '/tracks/'+track[2]+'.json', {}, callback, 'json'
        for track_marker in tracks_markers
          track_marker.setMap(null)
        # document.getElementById(track[2]).style.backgroundColor = 'silver'
        
        google.maps.event.addListener map, 'click', (evt) ->
          set_markers_zoom(map, tracks_markers, marker_center)
          track_path.setMap(null)
          if mousemarker? 
            mousemarker.setMap(null)
          elevation_chart.style.display = 'none'
          # for li in document.getElementsByClassName('content__thumbRace')
          #   li.style.backgroundColor = 'transparent'
          for track_marker in tracks_markers
            track_marker.setMap(map)

  load_tracks_markers = (tracks, map) ->
    for track in tracks by 1
      tracks_markers[_i] = new google.maps.Marker({
          position: new google.maps.LatLng(track[0], track[1]),
          map: map,
          id: track[2],
          icon: image_path(track[3]+'.svg')
        })
    for track_marker in tracks_markers
      google.maps.event.addListener(track_marker, 'click', load_track_on_click)
  
  if google?
    chart = new google.visualization.ColumnChart(elevation_chart)
    map = gm_init(gm_center)
    load_tracks_markers(js_tracks, map)
    marker_center = new google.maps.Marker({
      position: gm_center,
      map: map,
      icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
    })
    set_markers_zoom(map, tracks_markers, marker_center)
    add_chart_listener(map)


