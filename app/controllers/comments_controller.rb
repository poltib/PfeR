class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_forum

  def create
    @comment = @forum.comments.create(comment_params)
  	@comment.user_id = current_user.id
    if @comment.save
      redirect_to forum_path(@forum), :notice => 'Votre commentaire à été ajouté avec succès.'
    else
      render 'new'
    end
  end

  def destroy
    @comment = @forum.comments.find(params[:id])
    @comment.destroy
    redirect_to forum_path(@forum), :notice => 'Votre commentaire à été supprimé avec succès.'
  end

  private
    def comment_params
      params.require(:comment).permit(:comment)
    end

    def load_forum
      @forum = Forum.find_by_slug(params[:forum_id])
    end
end
