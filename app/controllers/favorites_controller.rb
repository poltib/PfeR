class FavoritesController < ApplicationController
  before_action :set_favorite, only: [:show, :edit, :update, :destroy]

  # GET /favorites
  # GET /favorites.json
  def index
    @favoritable = find_favoritable
    @favorites = @favoritable.favorites
  end

  # GET /favorites/1
  # GET /favorites/1.json
  def show
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

  # PATCH/PUT /favorites/1
  # PATCH/PUT /favorites/1.json
  def update
    respond_to do |format|
      if @favorite.update(favorite_params)
        format.html { redirect_to @favorite, notice: 'Favorite was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @favorite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favorites/1
  # DELETE /favorites/1.json
  def destroy
    @favorite.destroy
    redirect_to :back, :notice => 'Votre favorit à été supprimé avec succès.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
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
          return $1.classify.constantize.find(value)
        end
      end
      nil
    end
end
