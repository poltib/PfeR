class HappeningtracksController < ApplicationController
  before_action :authenticate_user!

  def new
    @happening = Happening.find(params[:happening_id])
    @track = Track.new
  end

  def create
    @happening = Happening.find(params[:happening_id])

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
      @happening.tracks << @track
    else
      @track = @happening.tracks.create(track_params)
    end
    
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
      params.require(:track).permit(:name, :route)
    end
end
