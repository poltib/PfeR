class Track < ActiveRecord::Base
  before_save :parse_file
  mount_uploader :route, RouteUploader
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.location = geo.postal_code
    end
  end
  after_validation :reverse_geocode

  validates :name, :description, presence: true

  has_many :favorites, :as => :favoritable, dependent: :destroy
  belongs_to :happening
  belongs_to :user
  has_many :images, :as => :imagable, dependent: :destroy
  has_many :forums, :as => :forumable, dependent: :destroy

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
      tmp_point.push(node.attr("lat").to_f)
      tmp_point.push(node.attr("lon").to_f)
      tmp_segment.push(tmp_point)
    end
  end
  
  # def polyline_points
  #   self.points.map(&:latlng)
  # end

  # def polyline
  #   Polylines::Encoder.encode_points(self.polyline_points)
  # end
end
