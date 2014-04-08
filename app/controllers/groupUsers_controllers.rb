class GroupUsersController < ApplicationController
  before_action :authenticate_user!
  def create
  	@user = User.find(params[:user_id])
    @grouper = Grouper.new(grouper_params)
    if @grouper.save
      redirect_to user_path(@user), :notice => 'L\'utilisateur à bien été ajouté à votre groupe'
    else
      render 'new'
    end
    
  end

  private
    def grouper_params
      params.permit(:user_id, :group_id)
    end
end