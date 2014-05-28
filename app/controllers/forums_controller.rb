class ForumsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_action :set_forum, only: [:show, :destroy, :update, :edit]
  def index
    @categories = Category.all
    if params[:category_id]
      if Category.exists?(:id => params[:category_id])
        @forums = Category.find(params[:category_id]).forums.order('updated_at')
        @active = [params[:category_id].to_i,Category.find(params[:category_id]).name]
      else
        redirect_to forums_path, :notice => 'Cette catégorie n\'existe pas.'
      end
    else
      @forums = Forum.all.order('created_at desc')
    end
  end

  def new
    @forum = Forum.new
    @categories = Category.all
    if params[:happening_id]
      @happening = Happening.find_by_slug(params[:happening_id])
    end
  end

  def show
  	@comment = Comment.new
  end

  def create
  	@forum = Forum.new(forum_params)
  	@forum.user_id = current_user.id
    if @forum.save
      redirect_to forum_path(@forum), :notice => 'Votre forum à été ajouté avec succès.'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @forum.update_attributes forum_params
        redirect_to forum_path(@forum), :notice => 'Votre forum à été mis à jour avec succès.'
    else
        render 'edit'
    end
  end

  def destroy
    @forum.destroy
    redirect_to forums_path, :notice => 'Votre forum à été supprimé avec succès.'
  end

  private
    def set_forum
      @forum = Forum.find_by_slug(params[:id])
    end
    def forum_params
      params.require(:forum).permit(:name, :post, :forumable_id, :forumable_type, :category_ids => [])
    end
end
