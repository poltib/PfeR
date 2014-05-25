class HappeningsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_action :set_happening, only: [:show, :edit, :update, :destroy]
  def index
    @happenings = Happening.search(params[:event_type], params[:date], params[:location])
    @previousHap = Happening.all.where('date <= ?', Date.today)
    @event_types = EventType.all
  end

  def new
    @happening = Happening.new
    @eventTypes = EventType.all
    if params[:group_id]
      @group = Group.find(params[:group_id])
    end
  end

  def show
    @location = [@happening.latitude, @happening.longitude]
    tracks = @happening.tracks
    @tracksJs = Array.new
    tracks.each do |track|
      @tracksJs.push([track.latitude, track.longitude, track.slug, track.length.to_f])
    end
    respond_to do |format|
      format.html # show.html.erb
      for track in @happening.tracks do
        format.json {
          render :json => track.to_json(:only => [:name, :polyline])
        }
      end
    end
  end

  def create
    @happening = Happening.new(happening_params)
    @happening.user = current_user
    if @happening.save
      redirect_to @happening, :notice => 'Votre évènement à été ajouté avec succès.'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @happening.update_attributes happening_params
        redirect_to happenings_path, :notice => 'Votre évènement à été mis à jour avec succès.'
    else
        render 'edit'
    end
  end

  def destroy
    @happening.destroy
    redirect_to happenings_path, :notice => 'Votre évènement à été supprimé avec succès'
  end

  private
    def set_happening
      @happening = Happening.find_by_slug(params[:id])
    end
    def happening_params
      params.require(:happening).permit(:name, :event_type_id, :description, :address, :link, :date, :route, :group_id)
    end

    def happening_search_params
      params.require(:search).permit()
    end
end
