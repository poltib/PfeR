class Track < ActiveRecord::Base
	before_save :parse_file
	mount_uploader :route, RouteUploader

	belongs_to :happening
  has_many :tracksegments, :dependent => :destroy
  has_many :points, :through => :tracksegments

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
      tmp_segment = Tracksegment.new
      node.elements.each do |node|
        parse_points(node,tmp_segment)
      end
      self.tracksegments << tmp_segment
    end
  end

  def parse_points(node,tmp_segment)
    if node.node_name.eql? 'trkpt'
      tmp_point = Point.new
      tmp_point.latitude = node.attr("lat")
      tmp_point.longitude = node.attr("lon")
      node.elements.each do |node|
        tmp_point.elevation = node.text.to_s if node.name.eql? 'ele'
      end
      tmp_segment.points << tmp_point
    end
  end
  
  def polyline_points
    self.points.map(&:latlng)
  end

  def polyline
    Polylines::Encoder.encode_points(self.polyline_points)
  end
end
