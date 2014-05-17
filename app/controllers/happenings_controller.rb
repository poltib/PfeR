class HappeningsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  def index
    @happenings = Happening.search(params[:event_type], params[:date], params[:location])
    @previousHap = Happening.all.where('date <= ?', Date.today)
    @event_types = EventType.all
  end

  def new
    @happening = Happening.new
    @eventTypes = EventType.all
  end

  def show
    @happening = Happening.find params[:id]
    @location = [@happening.latitude, @happening.longitude]
    tracks = @happening.tracks
    @tracksJs = Array.new
    tracks.each do |track|
      @tracksJs.push([track.latitude, track.longitude, track.id, track.length])
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
    @happening.user_id = current_user.id
    if @happening.save
      redirect_to happenings_path, :notice => 'Votre évènement à été ajouté avec succès.'
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
        redirect_to happenings_path, :notice => 'Votre évènement à été mis à jour avec succès.'
    else
        render 'edit'
    end
  end

  def destroy
    Happening.destroy params[:id]
    redirect_to happenings_path, :notice => 'Votre évènement à été supprimé avec succès'
  end

  private
    def happening_params
      params.require(:happening).permit(:name, :event_type_id, :description, :address, :link, :date, :route)
    end

    def happening_search_params
      params.require(:search).permit()
    end
end
