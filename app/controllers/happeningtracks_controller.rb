class HappeningtracksController < ApplicationController
  before_action :authenticate_user!

  def new
    @happening = Happening.find(params[:happening_id])
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
      redirect_to happening_path(@happening), :notice => 'Your track has been successfully created!'
    else
      render 'new'
    end
  end

  def destroy
    @forum = Forum.find(params[:forum_id])
    @comment = @forum.comments.find(params[:id])
    @comment.destroy
    redirect_to forum_path(@forum), :notice => 'Your comment has been successfully deleted!'
  end

  private
    def track_params
      params.require(:track).permit(:name, :polyline, :description, :longitude, :latitude, :location, :distance, :route)
    end
end
