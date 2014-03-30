class ForumsController < ApplicationController
  def index
    @forums = Forum.all.order("created_at desc")
  end

  def new
  	@forum = Forum.new
  end

  def show
  	@forum = Forum.find params[:id]
  	@comment = Comment.new
  end

  def create
  	@forum = Forum.new(forum_params)
  	@forum.user_id = current_user.id
    if @forum.save
      redirect_to forums_path, :notice => 'Your forum has been successfully created!'
    else
      render 'new'
    end
  end

  def edit
    @forum = Forum.find params[:id]
  end

  def update
    @forum = Forum.find params[:id]

    if @forum.update_attributes forum_params
        redirect_to forums_path, :notice => 'Your forum has been successfully updated!'
    else
        render 'edit'
    end
  end

  def destroy
    Forum.destroy params[:id]
    redirect_to :back, :notice => 'Your forum has been successfully deleted!'
  end

  private
    def forum_params
      params.require(:forum).permit(:title, :post)
    end
end
