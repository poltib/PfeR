class HappeningsController < ApplicationController
  def index
    @happenings = Happening.all
  end

  def new
  	@happening = Happening.new
  end

  def show
  	@happening = Happening.find params[:id]
  	@fileExt = File.extname(@happening.route.current_path)

  	if @fileExt == '.tcx'
	  	xml = Nokogiri::XML(open(@happening.route.current_path))
			@coords = xml.search('Trackpoint').map do |coord| 
			  %w[LatitudeDegrees LongitudeDegrees].each_with_object({}) do |n, o|
			    o[n] = coord.at(n).text
			  end
			end
		end

		if @fileExt == '.gpx'
	  	xml = Nokogiri::XML(open(@happening.route.current_path))
			@coords = xml.search('trkpt') do |coord| 
			end
		end
  end

  def create
    require 'builder'
    file = File.new(Rails.root.join("public", "route.xml"), "w")

    xml = Builder::XmlMarkup.new(:target=>file, :indent => 2)
    xml.instruct!
    xml.kml(
      "xmlns" => "http://www.opengis.net/kml/2.2",
      "xmlns:gx" => "http://www.google.com/kml/ext/2.2",
      "xmlns:kml" => "http://www.opengis.net/kml/2.2",
      "xmlns:atom" => "http://www.w3.org/2005/Atom"){
      xml.Document{
        xml.Placemark{
          xml.Name(happening_params[:name])
          xml.LineString{
            xml.Coordinates(happening_params[:route].gsub(/[\(-\)]/, ""))
          }
        }
      }
    }

  	@happening = Happen ing.new(happening_params)
  	@happening.user_id = current_user.id
    if @happening.save
      redirect_to happenings_path, :notice => 'Your happening has been successfully created!'
    else
      render 'new'
    end
  end

  def edit
    @happening = Happening.find params[:id]
  end

  def update
    @happening = Happening.find params[:id]

    if @happening.update_attributes happening_params
        redirect_to happenings_path, :notice => 'Your happening has been successfully updated!'
    else
        render 'edit'
    end
  end

  def newusers
    @happening = Happening.find params[:id]
  end

  def addusers
    @happening = Happening.find params[:id]
    @users = param
    
  end

  def destroy
    Happening.destroy params[:id]
    redirect_to :back, :notice => 'Your happening has been successfully deleted!'
  end

  def confirm_destroy
  	@happening = Happening.find(params[:id])
  end

  private
    def happening_params
      params.require(:happening).permit(:name, :description, :address, :link, :date, :route, :city, :postalCode, :country)
    end
end
