class HappeningtracksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_track, only: [:destroy]
  before_action :set_location, only: [:index, :new]

  def new
    @happening = Happening.find(params[:happening_id])
    @location = [@happening.latitude, @happening.longitude]
    @track = Track.new
  end

  def create
    @happening = Happening.find(params[:happening_id])
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
    @happening.tracks << @track
    if @track.save
      redirect_to happening_path(@happening), :notice => 'Le tracé à été ajouté avec succès.'
    else
      render 'new'
    end
  end

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

    def track_params
      params.require(:track).permit(:name, :polyline, :description, :longitude, :latitude, :location, :length, :route)
    end
end
