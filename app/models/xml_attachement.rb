class XmlAttachement < ActiveRecord::Base
  mount_uploader :uploaded_file, RouteUploader

  belongs_to :track

  def create_kml_file(name, route, track_id)
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.send( 'kml',
        'xmlns' => 'http://www.opengis.net/kml/2.2',
        'xmlns:gx' => 'http://www.google.com/kml/ext/2.2',
        'xmlns:kml' => 'http://www.opengis.net/kml/2.2',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom'){
        xml.send('Document') {
          xml.send('Placemark') {
            xml.send('Name'){xml.text name}
            xml.send('LineString'){
              xml.send('Coordinates'){
                route.each do |coords|
                  xml.text coords[0].to_s+","+coords[1].to_s+","+coords[2].to_s
                end
              }
            }
          }
        }
      }
    end
    file_to_upload = File.open(name+".kml", "w")     
    file_to_upload.write(builder.to_xml)
    file_to_upload.close()
    self.uploaded_file = File.open(name+".kml")
    self.track_id = track_id
    self.save!
  end

  def create_gpx_file(name, route, track_id)
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.send( 'gpx',
        'version' => '1.1',
        'creator' => 'Sportfun - find races and tracks, http://sportfun.herokuapp.com',
        'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd',
        'xmlns' => 'http://www.topografix.com/GPX/1/1',
        'xmlns:gpxtpx' => 'http://www.garmin.com/xmlschemas/TrackPointExtension/v1',
        'xmlns:gpxx' => 'http://www.garmin.com/xmlschemas/GpxExtensions/v3',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'){
        xml.metadata(){
          xml.link(:href => 'http://sportfun.herokuapp.com'){
            xml.text_ "Sportfun"
          }
          xml.time Time.now.iso8601
        }
        xml.trk(){
          route.each do |coords|
            xml.trkseg(){
              xml.trkpt(:lon => coords[1], :lat => coords[0]){
                xml.ele coords[2]
              }
            }
          end
        }
      }
    end
    file_to_upload = File.open(name+".gpx", "w")     
    file_to_upload.write(builder.to_xml)
    file_to_upload.close()
    self.uploaded_file = File.open(name+".gpx")
    self.track_id = track_id
    self.save!
  end
end