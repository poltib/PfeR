class UserStatusesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_status, only: [:destroy]
  before_filter :load_happening
  def index
  	@user_statuses = @happening.user_statuses
  end

  def create
  	@user_status = @happening.user_statuses.build(status_params)
    @user_status.user = current_user
    if @user_status.save
      # @user_status.create_activity :create, owner: current_user
      redirect_to @happening, notice: "Vous participez à la course."
    else
      render :new
    end
  end

  def destroy
    @user_status.destroy
    redirect_to :back, :notice => 'Vous ne participez plus à cette course.'
  end

private
  def set_user_status
    @user_status = UserStatus.find(params[:id])
  end

  def load_happening
    @happening = Happening.find(params[:happening_id])
  end

  def status_params
    params.require(:user_status).permit(:user_id, :happening_id)
  end
end