class CommentsController < ApplicationController
  before_action :authenticate_user!
  def create
  	@forum = Forum.find(params[:forum_id])
    @comment = @forum.comments.create(comment_params)
  	@comment.user_id = current_user.id
    if @comment.save
      redirect_to forum_path(@forum), :notice => 'Your comment has been successfully created!'
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
    def comment_params
      params.require(:comment).permit(:comment)
    end
end
