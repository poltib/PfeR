class TracksController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_action :set_track, only: [:show, :edit, :update, :destroy]
  before_action :set_location, only: [:index, :new]

  # GET /tracks
  # GET /tracks.json
  def index
    @user = request.location
    @tracks = Track.near(@location, 10, :units => :km)
    @tracksJs = Array.new
    for track in @tracks do
      @tracksJs.push([track.latitude, track.longitude, track.id, track.length])
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
  end

  # GET /tracks/1/edit
  def edit
  end

  # POST /tracks
  # POST /tracks.json
  def create
    @track = Track.new(track_params)
    if !track_params[:route]
      tmp_segment = track_params[:polyline].scan(/(\d+.\d+),(\d+.\d+)/).to_a
      for coords in tmp_segment do
        coords[0] = coords[0].to_f
        coords[1] = coords[1].to_f
      end
      @track.polyline = Polylines::Encoder.encode_points(tmp_segment)
    end
    @track.user_id = current_user.id
    respond_to do |format|
      if @track.save
        format.html { redirect_to @track, notice: 'Le tracé à été ajouté avec succès.' }
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
        format.html { redirect_to @track, notice: 'Le tracé à été mis à jour avec succès.' }
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
      format.html { redirect_to tracks_url, notice: 'Le tracé à été supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_track
      @track = Track.find(params[:id])
    end

    def set_location
      user_location = request.location
      if user_location.latitude === 0.0 && user_location.longitude === 0.0
        @location = [50.633333, 5.566667]
      else
        @location = Array.new(request.location.latitude, request.location.longitude)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def track_params
      params.require(:track).permit(:name, :longitude, :latitude, :description, :polyline, :location, :length, :route)
    end
end
