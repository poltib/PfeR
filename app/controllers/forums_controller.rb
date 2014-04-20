class ForumsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  def index
    @forums = Forum.all.order("created_at desc")
    @categories = Category.all
  end

  def new
    @forum = Forum.new
    @categories = Category.all
  end

  def show
  	@forum = Forum.find params[:id]
  	@comment = Comment.new
  end

  def create
  	@forum = Forum.new(forum_params)
  	@forum.user_id = current_user.id
    for category in params[:forum][:categories] do 
      if category != ""
        @forum.categories << Category.find(category.to_i)
      end
    end
    if @forum.save
      redirect_to forums_path, :notice => 'Votre forum à été ajouté avec succès.'
    else
      render 'new'
    end
  end

  def edit
    @forum = Forum.find params[:id]
  end

  def update
    @forum = Forum.find params[:id]
    for category in params[:forum][:categories] do 
      if category != ""
        @forum.categories << Category.find(category.to_i)
      end
    end
    if @forum.update_attributes forum_params
        redirect_to forums_path, :notice => 'Votre forum à été mis à jour avec succès.'
    else
        render 'edit'
    end
  end

  def destroy
    Forum.destroy params[:id]
    redirect_to :back, :notice => 'Votre forum à été supprimé avec succès.'
  end

  private
  
  def forum_params
    params.require(:forum).permit(:name, :categories, :post)
  end
end
