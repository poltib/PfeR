class TracksController < ApplicationController
  before_action :set_track, only: [:show, :edit, :update, :destroy]

  # GET /tracks
  # GET /tracks.json
  def index
    @tracks = Track.all
  end

  # GET /tracks/1
  # GET /tracks/1.json
  def show
    @track = Track.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => @track.to_json(:methods => [:polyline],:only => [:name])
      }
    end
  end

  # GET /tracks/new
  def new
    @track = Track.new
  end

  # GET /tracks/1/edit
  def edit
  end

  # POST /tracks
  # POST /tracks.json
  def create
    if track_params[:route].is_a? String
      @track = Track.new
      tracksegment = Tracksegment.new
      coords = track_params[:route].scan(/(\d+.\d+),(\d+.\d+),(\d+.\d+)/).to_a
      for coord in coords do
        point = Point.new
        point.longitude = coord[0]
        point.latitude = coord[1]
        point.elevation = coord[2]
        tracksegment.points << point
      end
      @track.tracksegments << tracksegment
      track_params[:route] = ""
      @track.name = track_params[:name]
    else
      @track = Track.new(track_params)
    end

    respond_to do |format|
      if @track.save
        format.html { redirect_to @track, notice: 'Track was successfully created.' }
        format.json { render action: 'show', status: :created, location: @track }
      else
        format.html { render action: 'new' }
        format.json { render json: @track.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tracks/1
  # PATCH/PUT /tracks/1.json
  def update
    respond_to do |format|
      if @track.update(track_params)
        format.html { redirect_to @track, notice: 'Track was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @track.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.json
  def destroy
    @track.destroy
    respond_to do |format|
      format.html { redirect_to tracks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_track
      @track = Track.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def track_params
      params.require(:track).permit(:name, :route)
    end
end
