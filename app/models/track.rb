class Track < ActiveRecord::Base
  # before_save :parse_file
  before_save :create_polyline
  # mount_uploader :route, RouteUploader
  before_save :create_slug
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.location = geo.postal_code
    end
  end
  after_validation :reverse_geocode

  validates :name, :description, presence: true
  validates :name, uniqueness: true

  has_many :favorites, :as => :favoritable, dependent: :destroy
  belongs_to :happening
  belongs_to :user
  belongs_to :group
  has_many :xml_attachements, dependent: :destroy
  has_many :images, :as => :imagable, dependent: :destroy
  has_many :forums, :as => :forumable, dependent: :destroy

  def to_param
    slug
  end

  def create_slug
    self.slug = self.name.parameterize
  end

  def create_polyline
    tmp_segment = polyline.scan(/\((\d+\.\d+|\d+)\|(\d+\.\d+|\d+)\|(\d+\.\d+|\d+)\)/).to_a
    gpx_file = XmlAttachement.new
    gpx_file.create_gpx_file(name, tmp_segment, id.to_s)
    self.xml_attachements << gpx_file
    tmp_segment.each do |coords|
      coords[0] = coords[0].to_f
      coords[1] = coords[1].to_f
      coords.delete(coords[2])
    end
    self.polyline = Polylines::Encoder.encode_points(tmp_segment)
  end

  def parse_file
    if route.path
      tempfile = File.open(route.path)
      doc = Nokogiri::XML(tempfile)
      parse_xml(doc)
    end
  end

  def parse_xml(doc)
    doc.root.elements.each do |node|
      parse_tracks(node)
    end
  end

  def parse_tracks(node)
    if node.node_name.eql? 'trk'
      node.elements.each do |node|
        parse_track_segments(node)
      end
    end
  end

  def parse_track_segments(node)
    if node.node_name.eql? 'trkseg'
      tmp_segment = []
      node.elements.each do |node|
        parse_points(node,tmp_segment)
      end
      self.polyline = Polylines::Encoder.encode_points(tmp_segment)
      self.latitude = tmp_segment[0][0]
      self.longitude = tmp_segment[0][1]
    end
  end

  def parse_points(node,tmp_segment)
    if node.node_name.eql? 'trkpt'
      tmp_point = []
      tmp_point.push(node.attr('lat').to_f)
      tmp_point.push(node.attr('lon').to_f)
      tmp_segment.push(tmp_point)
    end
  end

  def self.create_kml_file(name, route, id)
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
    FileUtils::mkdir_p Rails.root.join('public/tracks', id)
    File.open(Rails.root.join('public/tracks/'+id+'/', name+'.kml'), 'w+') do |f|
      f.write(builder.to_xml)
    end
  end

  def self.create_gpx_file(name, route, id)
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
    File.open(Rails.root.join('public/tracks/'+id+'/', name+'.gpx'), 'w+') do |f|
      f.write(builder.to_xml)
    end
  end
  
  # def polyline_points
  #   self.points.map(&:latlng)
  # end

  # def polyline
  #   Polylines::Encoder.encode_points(self.polyline_points)
  # end
end
