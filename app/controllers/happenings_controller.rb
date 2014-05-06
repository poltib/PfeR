class HappeningsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  def index
    @happenings = Happening.all
  end

  def new
    @happening = Happening.new
  end

  def show
    @happening = Happening.find params[:id]
    @location = [@happening.latitude, @happening.longitude]
    tracks = @happening.tracks
    @tracksJs = Array.new
    for track in tracks do
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

  def newusers
    @happening = Happening.find params[:id]
  end

  def addusers
    @happening = Happening.find params[:id]
    @users = param
    
  end

  def destroy
    Happening.destroy params[:id]
    redirect_to :back, :notice => 'Votre évènement à été supprimé avec succès'
  end

  def confirm_destroy
    @happening = Happening.find(params[:id])
  end

  private
    def happening_params
      params.require(:happening).permit(:name, :event_type, :description, :address, :link, :date, :route)
    end

    def happening_search_params
      params.require(:search).permit()
    end
end
