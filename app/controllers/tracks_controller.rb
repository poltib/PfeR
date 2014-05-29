class TracksController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :download]
  before_action :set_track, only: [:show, :destroy, :download]
  before_action :set_location, only: [:index, :new]
  before_action :set_radius, only: [:index]

  # GET /tracks
  # GET /tracks.json
  def index
    if params[:user_id]
      @user = User.find_by_username params[:user_id]
      @tracks = @user.tracks
    else
      @tracks = Track.near(@location, @radius, :units => :km)
    end
    @tracksJs = Array.new
    @tracks.each do |track|
      @tracksJs.push([track.latitude, track.longitude, track.slug])
    end
  end

  # GET /tracks/1
  # GET /tracks/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => @track.to_json(:only => [:name, :polyline])
      }
    end
  end

  # GET /tracks/new
  def new
    @track = Track.new
    if params[:happening_id]
      @happening = Happening.find_by_slug(params[:happening_id])
      @location = [@happening.latitude, @happening.longitude]
    end
  end

  # POST /tracks
  # POST /tracks.json
  def create
    @track = Track.new(track_params)
    if !track_params[:route]
      tmp_segment = track_params[:polyline].scan(/\((\d+\.\d+|\d+)\|(\d+\.\d+|\d+)\|(\d+\.\d+|\d+)\)/).to_a
      generate_segment = tmp_segment
      tmp_segment.each do |coords|
        coords[0] = coords[0].to_f
        coords[1] = coords[1].to_f
        coords.delete(coords[2])
      end
      @track.polyline = Polylines::Encoder.encode_points(tmp_segment)
    end
    @track.user = current_user
    if track_params[:happening_id]
      @happening = Happening.find_by_slug(track_params[:happening_id])
      @happening.tracks << @track
    end
    respond_to do |format|
      if @track.save
        Track.create_kml_file(track_params[:name], generate_segment, @track.id.to_s)
        Track.create_gpx_file(track_params[:name], generate_segment, @track.id.to_s)
        if track_params[:happening_id]
          format.html { redirect_to @happening, notice: 'Le tracé à été ajouté avec succès.' }
          format.json { render action: 'show', status: :created, location: @happening }
        else  
          format.html { redirect_to @track, notice: 'Le tracé à été ajouté avec succès.' }
          format.json { render action: 'show', status: :created, location: @track }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @track.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.json
  def destroy
    FileUtils.rm_rf(Rails.root.join("public/tracks/", @track.id.to_s))
    @track.destroy
    respond_to do |format|
      format.html { redirect_to tracks_url, notice: 'Le tracé à été supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  require 'zip'
  def download
    exts = ['.gpx', '.kml']
    if !@track.name.blank?
      file_name = @track.name+".zip"
      t = Tempfile.new(@track.name+"-#{Time.now}")
      Zip::OutputStream.open(t.path) do |z|
        exts.each do |ext|
          title = @track.name + ext
          z.put_next_entry(title)
          z.print IO.read(Rails.root.join('public/tracks/'+@track.id.to_s+'/', title))
        end
      end
      send_file t.path, :type => 'application/zip',
                        :disposition => 'attachment',
                        :filename => file_name
      t.close
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_track
      @track = Track.find_by_slug(params[:id])
    end

    def set_location
      if params[:search] && params[:search] != ""
        @location = Geocoder.coordinates(params[:search])
      else
        user_location = request.location
        if user_location.latitude === 0.0 && user_location.longitude === 0.0
          @location = [50.633333, 5.566667]
        else
          @location = [user_location.latitude, user_location.longitude]
        end
      end
    end

    def set_radius
      if params[:radius]
        @radius = params[:radius]
      else
        @radius = 30
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def track_params
      params.require(:track).permit(:happening_id, :name, :longitude, :latitude, :description, :polyline, :location, :length, :route, :group_id)
    end
end
