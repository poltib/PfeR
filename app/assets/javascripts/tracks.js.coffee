NUMBERS_DOT_THREENUMBERS = /^(\d+)(\d{3})(\.\d+)/
THREENUMBERS_DOT_NUMBERS = /^(\d{3})(\.\d+)/
COORD = /^(\d+\.)(\d{0,13})(\d+)/
poly = 1
chart = 1
elevations = 1
SAMPLES = 100
mousemarker = null
track_path = null
newRoute = []
dist_markers = []
jsInput = null
elevationReqActive = false
end_marker = null
start_marker = null

# Spiner

@PageSpinner =
  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:change', =>
      @remove_spinner()
  spinner_html: '
    <span class="div__loader"><em class="loader icon-cw"></em></span>
  '
  spinner: null
  add_spinner: ->
    $('.header__navbar').append(@spinner_html)
  remove_spinner: ->
    clearTimeout(@spinner)
    $('.div__loader').on 'hidden', ->
      $(this).remove()
 
$(document).on 'page:fetch', ->
  PageSpinner.spin()

if google?
  path = new google.maps.MVCArray()
  gm_service = new google.maps.DirectionsService()
  elevationService = new google.maps.ElevationService()
  google.load("visualization", "1", {packages: ["corechart"]})

gm_init = (gm_center) ->
  mapTypeIds = []
  mapTypeIds.push(google.maps.MapTypeId.ROADMAP)
  mapTypeIds.push(google.maps.MapTypeId.TERRAIN)
  mapTypeIds.push(google.maps.MapTypeId.SATELLITE)
  mapTypeIds.push(google.maps.MapTypeId.HYBRID)
  mapTypeIds.push("OSM")
  mapTypeIds.push("TFL")
  map_options = {
    zoom: 14,
    center: gm_center,
    backgroundColor: "rgb(255,255,255)",
    scrollwheel: false,
    mapTypeControlOptions: {
      mapTypeIds: mapTypeIds,
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
    }
  }
  map = new google.maps.Map(@map_canvas,map_options)
  map.mapTypes.set("OSM", new google.maps.ImageMapType({
    getTileUrl: (coord, zoom) ->
        return "http://tile.openstreetmap.org/" + zoom + "/" + coord.x + "/" + coord.y + ".png"
    tileSize: new google.maps.Size(256, 256),
    name: "OSM",
    maxZoom: 18
  }))
  map.mapTypes.set("TFL", new google.maps.ImageMapType({
    getTileUrl: (coord, zoom) ->
        return "http://tile.thunderforest.com/landscape/" + zoom + "/" + coord.x + "/" + coord.y + ".png"
    tileSize: new google.maps.Size(256, 256),
    name: "TF Landscape",
    maxZoom: 18
  }))
  map

poly_init = (map) ->
  poly_options = {
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
  newRoute = ''
  if jsInput?
    for coords in elevations by 1
      newRoute += '(' + coords.location.lat() + '|' + coords.location.lng() + '|' + coords.elevation + ')'
      jsInput.value = newRoute

  for elevation in elevations by 1
    data.addRow(['',elevation.elevation])

  # Draw the chart using the data within its DIV.
  elevation_chart.style.display = 'block'
  options = {
    height: 100,
    dataOpacity: 0.8,
    bar: {groupWidth: "100%"},
    legend: { position: "none" },
    titleY: 'Elevation (m)',
    fill: '#00AA00',
    vAxis: {minValue: 0},
    colors: ["#3498db"],
    focusBorderColor: '#00AA00',
    tooltip: { trigger: 'none' },
  }
  chart.draw(data, options)
  undefined

load_track = (id,map) ->
  callback = (data) -> display_on_map(data,map)
  $.get '/tracks/'+id+'.json', {}, callback, 'json'

createMarker = (map, latlng, dist) ->
  marker = new google.maps.Marker({
    position:latlng,
    map:map,
    size: new google.maps.Size(20, 20),
    icon: image_path(dist+'.svg'),
    anchor: new google.maps.Point(-10,-10)
  })

display_on_map = (data,map) ->
  decoded_path = google.maps.geometry.encoding.decodePath(data.polyline)
  # icon_set = { path: google.maps.SymbolPath.FORWARD_OPEN_ARROW }
  path_options = { path: decoded_path, strokeColor: "black",strokeOpacity: 0.8,map: map, strokeWeight: 5}
  track_path = new google.maps.Polyline(path_options)
  drawPath(decoded_path)
  map.fitBounds(calc_bounds(track_path))
  start_marker = new google.maps.Marker({
    map: map,
    position: new google.maps.LatLng(decoded_path[0].lat(), decoded_path[0].lng()),
    icon: "http://maps.google.com/mapfiles/dd-start.png"
  })
  end_marker = new google.maps.Marker({
    map: map,
    position: new google.maps.LatLng(decoded_path[decoded_path.length - 1].lat(), decoded_path[decoded_path.length - 1].lng()),
    icon: "http://maps.google.com/mapfiles/dd-end.png"
  })
  km_number=1
  length = google.maps.geometry.spherical.computeLength(track_path.getPath())
  remainingDist = length
  while remainingDist > 0
    dist_markers.push(createMarker(map, track_path.GetPointAtDistance(1000*km_number),km_number))
    remainingDist -= 1000
    km_number++
  static_map = "http://maps.googleapis.com/maps/api/staticmap?size=400x400&path=weight:5%7Ccolor:black%7Cenc:"+ data.polyline
  document.getElementById("mapstat").setAttribute("content",static_map)


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

$(".tracks.new").ready ->
  # Controls
  dist = document.getElementById "dist"
  reset = document.getElementById "reset"
  close = document.getElementById "close"
  clear = document.getElementById "clear"
  full = document.getElementById "full"
  hide_button = document.getElementById('hideMap')
  back_button = document.getElementById('back')
  tiny_button = document.getElementById('tiny')
  help = document.getElementById("help")
  # map
  divMap = document.getElementById "map_canvas"
  # form inputs
  jsInput = document.getElementById("jsRoute");
  distanceInput = document.getElementById("track_length");
  longitude_input = document.getElementById("track_longitude");
  latitude_input = document.getElementById("track_latitude");
  upLi = document.getElementById("upRoute");
  # form errors
  mapErrors = document.getElementById("mapErrors");
  # chart
  elevation_chart = document.getElementById('elevation_chart')
  chart = new google.visualization.ColumnChart(elevation_chart);
  # global variables
  previous_point = []
  map = null

  create_track = (latLng, map) ->
    path.push(latLng)
    poly.setPath(path)
    latitude_input.value = latLng.lat()
    longitude_input.value = latLng.lng()
    start_marker = new google.maps.Marker({
      map: map,
      position: latLng,
      icon: "http://maps.google.com/mapfiles/dd-start.png"
    })

  extend_track = (origin, destination) ->
    gm_service.route({
      origin: origin,
      destination: destination,
      travelMode: google.maps.DirectionsTravelMode.WALKING
    }, (result, status) ->
      return if status != google.maps.DirectionsStatus.OK
      for i in result.routes[0].overview_path by 1
        path.push(i)
      drawPath(path.j)
      update_dist()
      end_marker.setMap(map)
      end_marker.setPosition(destination)
      undefined
    )

  update_dist = () ->
    track_dist = google.maps.geometry.spherical.computeLength(poly.getPath()).toString()
    if track_dist.match(THREENUMBERS_DOT_NUMBERS)?
      track_dist = track_dist.replace(THREENUMBERS_DOT_NUMBERS, '0.$1')
    else
      track_dist = track_dist.replace(NUMBERS_DOT_THREENUMBERS, '$1.$2')
    dist.childNodes[0].textContent = track_dist + 'km'
    distanceInput.value = track_dist

  truncate_track = () ->
    if path.j.length <= 2
      clear_all()
    else
      path.j.pop()
      poly.setPath(path)
      drawPath(path.j)
      new_pos = gm_center = new google.maps.LatLng(path.j[path.j.length - 1].lat(), path.j[path.j.length - 1].lng())
      end_marker.setPosition(new_pos)
      update_dist()

  undo_action = () ->
    if previous_point.length >= 2
      tmp_previous_point = path.j.length - previous_point[previous_point.length - 1]
      tmp_path = path.j.slice(0).reverse()
      for number in path.j.slice(0).reverse() when _i < tmp_previous_point
        tmp_path.shift()
      path.j = tmp_path.slice(0).reverse()
      poly.setPath(path)
      drawPath(path.j)
      new_pos = gm_center = new google.maps.LatLng(path.j[path.j.length - 1].lat(), path.j[path.j.length - 1].lng())
      end_marker.setPosition(new_pos)
      previous_point.pop()
      update_dist()
    else
      clear_all()

  clear_all = () ->
    path.clear()
    previous_point = []
    elevation_chart.style.display = 'none'
    dist.childNodes[0].nodeValue = '0km'
    latitude_input.value = ''
    longitude_input.value = ''
    distanceInput.value = ''
    jsInput.value = ''
    if start_marker?
      start_marker.setMap(null)
    if end_marker?
      end_marker.setMap(null)
    if mousemarker?
      mousemarker.setMap(null)

  init = () ->
    clear_all()
    gm_center = new google.maps.LatLng(js_location[0], js_location[1])
    map = gm_init(gm_center)
    map.setOptions({draggableCursor:"crosshair"})
    # upLi.style.display = 'none' 
    poly = poly_init(map)
    add_chart_listener(map)
    marker_center = new google.maps.Marker({
      map: map,
      position: gm_center,
      icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
    })
    end_marker = new google.maps.Marker({
      map: map,
      icon: "http://maps.google.com/mapfiles/dd-end.png"
    })
    reset.addEventListener 'click', (evt) ->
      clear_all()

    tiny_button.addEventListener 'click', (evt) ->
      truncate_track()

    back_button.addEventListener 'click', (evt) ->
      undo_action()

    close.addEventListener 'click', (evt) ->
      if path.getLength() != 0
        extend_track(path.getAt(path.j.length - 1),path.getAt(0))

    # hide_button.addEventListener 'click', (evt)->
    #   if upLi.style.display == "block"
    #     hide_button.childNodes[0].textContent = "Créer avec un fichier"
    #     upLi.style.display = 'none'
    #     document.getElementsByClassName('map')[0].style.display = 'block'
    #   else
    #     upLi.style.display = 'block'
    #     document.getElementsByClassName('map')[0].style.display = 'none'
    #     hide_button.childNodes[0].textContent = "Créer sur la carte"

    $('.createForm').submit ->
      if jsInput.value == '' || jsInput.value != jsInput.value.match(/\((\d+\.\d+|\d+)\|(\d+\.\d+|\d+)\|(\d+\.\d+|\d+)\)/).input
        mapErrors.style.display = 'block'
        mapErrors.childNodes[1].innerText = 'Vous devez créer un tracé'
        false


    # full.addEventListener 'click', (evt) ->
    #   divMap.style.width = '100%'
    #   divMap.style.z-index = '100000'

    google.maps.event.addListener map, 'click', (evt) ->
      if path.getLength() == 0
        create_track(evt.latLng, map)
      else
        previous_point.push(path.j.length - 1)
        extend_track(path.getAt(path.j.length - 1), evt.latLng)

    help.addEventListener 'click', ()->
      introJs().start()

  init()
  

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

$(".registrations.edit").ready ->
  password_form = document.getElementById("edit__password")
  show_form_button = document.getElementById("showPasswordForm")
  if password_form? 
    password_form.style.display = "none"

  if show_form_button
    show_form_button.addEventListener 'click', (evt) ->
      if password_form.style.display == "block"
        password_form.style.display = "none"
      else
        password_form.style.display = "block"

$(".tracks.index, .happenings.show").ready ->
  $( '#many a.thumbnail' ).heplbox()
  image_form = document.getElementById("addImage")
  show_form_button = document.getElementById("showImageForm")
  tracks_markers = []
  marker_center = null
  gm_center = new google.maps.LatLng(js_location[0], js_location[1])
  radius = document.getElementById("radius")
  elevation_chart = document.getElementById('elevation_chart')

  if image_form? 
    image_form.style.display = "none"

  if show_form_button
    show_form_button.addEventListener 'click', (evt) ->
      if image_form.style.display == "block"
        image_form.style.display = "none"
      else
        image_form.style.display = "block"

  load_track_on_click = (evt) ->
    for track in js_tracks by 1
      # replace take the 13 decimals of a coord because creating a marker with coords change them
      if track[0].toString().replace(COORD, '$1$2') == evt.latLng.lat().toString().replace(COORD, '$1$2') && track[1].toString().replace(COORD, '$1$2') == evt.latLng.lng().toString().replace(COORD, '$1$2')
        callback = (data) -> display_on_map(data,map)
        $.get '/tracks/'+track[2]+'.json', {}, callback, 'json'
        for track_marker in tracks_markers
          track_marker.setMap(null)
        
        google.maps.event.addListener map, 'click', (evt) ->
          track_path.setMap(null)
          start_marker.setMap(null)
          end_marker.setMap(null)
          if mousemarker? 
            mousemarker.setMap(null)
          elevation_chart.style.display = 'none'
          for dist_marker in dist_markers
            dist_marker.setMap(null)
          for track_marker in tracks_markers
            track_marker.setMap(map)

  if radius?
    radius.onchange = ()->
      document.getElementById('actuRadius').innerHTML = radius.value

  load_tracks_markers = (tracks, map) ->
    for track in tracks by 1
      tracks_markers.push(new google.maps.Marker({
        position: new google.maps.LatLng(track[0], track[1]),
        map: map,
        id: track[2],
        icon: image_path(track[3]+'.svg')
      }))
    for track_marker in tracks_markers
      google.maps.event.addListener(track_marker, 'click', load_track_on_click)

  load_map = () ->
    for track_marker in tracks_markers
      track_marker.setMap(null)
    tracks_markers = []
    load_tracks_markers(js_tracks, map)
    marker_center.setPosition(gm_center)
    set_markers_zoom(map, tracks_markers, marker_center)

  if document.getElementById("map_canvas")?
    chart = new google.visualization.ColumnChart(elevation_chart)
    map = gm_init(gm_center)
    search = document.getElementById('search-form')
    searchBox = new google.maps.places.SearchBox(document.getElementById('search')) if search?
    marker_center = new google.maps.Marker({
      map: map,
      icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
    })
    load_map()
    add_chart_listener(map)

$(".users.show").ready ->
  first_user = document.getElementById("tour")
  help = document.getElementById("help")

  if help?
    if !help.addEventListener
      help.attachEvent "onclick", ()->
        introJs().start()
    else
      help.addEventListener("click", ()->
        introJs().start()
      , false)

  if first_user? && first_user.innerText == 'true'
    introJs().start()

$(".happenings.show").ready ->
  first_user = document.getElementById("tour")
  help = document.getElementById("help")
  if help?
    if !help.addEventListener
      help.attachEvent "onclick", ()->
        introJs().start()
    else
      help.addEventListener("click", ()->
        introJs().start()
      , false)

  if first_user? && first_user.innerText == 'true'
    introJs().start()

$(".users.show, .happenings.show, .forums.show, .tracks.show, .groups.show, .users.index, .happenings.index, .tracks.index, .groups.index, .favorites.index").ready ->
  toggle_actions = document.getElementById("toggle_actions_bar")
  actions_menu = $("#actions__menu")

  checkWidth = ()->
    width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
    if width < 925
      actions_menu.addClass('hidden')
      toggle_actions.style.display = 'block'
    else
      actions_menu.removeClass('hidden')
      toggle_actions.style.display = 'none'

  if actions_menu? && toggle_actions?
    checkWidth()
    $(window).resize(checkWidth)
    if !toggle_actions.addEventListener
      toggle_actions.attachEvent "onclick", ()->
        if actions_menu.attr('class') == 'hidden'
          actions_menu.removeClass('hidden')
        else
          actions_menu.addClass('hidden')
    else
      toggle_actions.addEventListener('click', ()->
        if actions_menu.attr('class') == 'hidden'
          actions_menu.removeClass('hidden')
        else
          actions_menu.addClass('hidden')
      , false)
      