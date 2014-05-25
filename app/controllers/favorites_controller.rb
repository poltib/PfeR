class FavoritesController < ApplicationController
  before_action :set_favorite, only: [:destroy]

  # GET /favorites
  # GET /favorites.json
  def index
    @favoritable = find_favoritable
    @favorites = @favoritable.favorites
  end

  # POST /favorites
  # POST /favorites.json
  def create
    @favoritable = favorite_params[:favoritable_type].constantize.find favorite_params[:favoritable_id]
    @favorite = @favoritable.favorites.build(favorite_params)
    if @favorite.save
      flash[:notice] = "Ajouté aux favorits."
      redirect_to @favoritable
    else
      render :action => 'new'
    end
  end

  # DELETE /favorites/1
  # DELETE /favorites/1.json
  def destroy
    @favorite.destroy
    redirect_to :back, :notice => 'Votre favorit à été supprimé avec succès.'
  end

  private
    def set_favorite
      @favorite = Favorite.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_params
      params.require(:favorite).permit(:user_id, :favoritable_id, :favoritable_type)
    end

    def find_favoritable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find_by_slug(value)
        end
      end
      nil
    end
end
